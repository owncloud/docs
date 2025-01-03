"use strict";

// Standard library
const path = require("path");
const stream = require("stream");

// Third-party dependencies
const uuid = require("uuid");
const mime = require("mime");
const combinedStream2 = require("combined-stream2");
const Promise = require("bluebird");
const debug = require("debug")("form-data2");

const CRLF = "\r\n";

// Utility functions
const ofTypes = function(obj, types) {
	let match = false;
	for (let type of types) {
		match = match || obj instanceof type;
	}
	return match;
};

function assign(...objects) {
	let validObjects = objects.filter((object) => object != null);

	if (validObjects.length === 0) {
		return {};
	} else if (validObjects.length === 1) {
		return validObjects[0];
	} else {
		return Object.assign(...validObjects);
	}
}

module.exports = class FormData {
	constructor() {
		this._firstHeader = false;
		this._closingHeaderAppended = false;
		this._boundary = "----" + uuid.v4();
		this._headers = { "content-type": `multipart/form-data; boundary=${this._boundary}` };
		this._stream = combinedStream2.create();
	}

	_getStreamMetadata(source, options) { // FIXME: Make work with deferred sources (ie. callback-provided)
		let contentLength, contentType, filename, left;
		debug("obtaining metadata for source: %s", source.toString().replace(/\n/g, "\\n").replace(/\r/g, "\\r"));
		const fullPath = (left = options.filename != null ? options.filename : __guard__(source.client != null ? source.client._httpMessage : undefined, x => x.path)) != null ? left : source.path;

		if (fullPath != null) { // This is a file...
			let left1, left2;
			filename = path.basename(fullPath);
			contentType = (left1 = options.contentType != null ? options.contentType : (source.headers != null ? source.headers["content-type"] : undefined)) != null ? left1 : mime.lookup(filename);
			contentLength = (left2 = options.knownLength != null ? options.knownLength : options.contentLength) != null ? left2 : (source.headers != null ? source.headers["content-length"] : undefined); // FIXME: Is this even used anywhere?
		} else { // Probably just a plaintext form value, or an unidentified stream
			let left3;
			contentType = options.contentType != null ? options.contentType : (source.headers != null ? source.headers["content-type"] : undefined);
			contentLength = (left3 = options.knownLength != null ? options.knownLength : options.contentLength) != null ? left3 : (source.headers != null ? source.headers["content-length"] : undefined);
		}

		return {filename, contentType, contentLength};
	}

	_generateHeaderFields(name, metadata) {
		debug("generating headers for: %s", metadata);
		const headerFields = [];

		if (metadata.filename != null) {
			const escapedFilename = metadata.filename.replace('"', '\\"');
			headerFields.push(`Content-Disposition: form-data; name=\"${name}\"; filename=\"${escapedFilename}\"`);
		} else {
			headerFields.push(`Content-Disposition: form-data; name=\"${name}\"`);
		}

		if (metadata.contentType != null) {
			headerFields.push(`Content-Type: ${metadata.contentType}`);
		}

		debug("generated headers: %s", headerFields);
		return headerFields.join(CRLF);
	}

	_appendHeader(name, metadata) {
		let leadingCRLF;
		if (this._firstHeader === false) {
			debug("appending header");
			leadingCRLF = "";
			this._firstHeader = true;
		} else {
			debug("appending first header");
			leadingCRLF = CRLF;
		}

		const headerFields = this._generateHeaderFields(name, metadata);

		return this._stream.append(new Buffer(leadingCRLF + `--${this._boundary}` + CRLF + headerFields + CRLF + CRLF));
	}

	_appendClosingHeader() {
		debug("appending closing header");
		return this._stream.append(new Buffer(CRLF + `--${this._boundary}--`));
	}

	append(name, source, options) {
		if (options == null) { options = {}; }
		debug("appending source");
		if (this._closingHeaderAppended) {
			throw new Error("The stream has already been prepared for usage; you either piped it or generated the HTTP headers. No new sources can be appended anymore.");
		}

		if (!ofTypes(source, [stream.Readable, stream.Duplex, stream.Transform, Buffer, Function]) && (typeof source !== "string")) {
			throw new Error("The provided value must be either a readable stream, a Buffer, a callback providing either of those, or a string.");
		}

		if (typeof source === "string") {
			source = new Buffer(source); // If the string isn't UTF-8, this won't end well!
			if (options.contentType == null) { options.contentType = "text/plain"; }
		}

		const metadata = this._getStreamMetadata(source, options);
		this._appendHeader(name, metadata);

		return this._stream.append(source, options);
	}

	done() {
		// This method should be called when the user is finished adding streams. It adds the termination header at the end of the combined stream. When piping, this method is automatically called!
		debug("called 'done'");

		if (!this._closingHeaderAppended) {
			this._closingHeaderAppended = true;
			return this._appendClosingHeader();
		}
	}

	getBoundary() {
		return this._boundary;
	}

	getHeaders(callback) {
		// Returns the headers needed to correctly transmit the generated multipart/form-data blob. We will first need to call @done() to make sure that the multipart footer is there - from this point on, no new sources can be appended anymore.
		this.done();

		return Promise.try(() => {
			return this._stream.getCombinedStreamLength();
		}).then(function(length) {
			debug("total combined stream length: %s", length);
			return Promise.resolve({ "content-length": length });
		}).catch(function(_error) {
			// We couldn't get the stream length, most likely there was a stream involved that `stream-length` does not support.
			debug("WARN: could not get total combined stream length");
			return Promise.resolve({ "transfer-encoding": "chunked" });
		}).then(sizeHeaders => {
			return Promise.resolve(assign(sizeHeaders, this._headers));
		}).nodeify(callback);
	}

	getLength(callback) {
		return this._stream.getCombinedStreamLength(callback);
	}

	pipe(target) {
		this.done();

		// Pass through to the underlying `combined-stream`.
		debug("piping underlying combined-stream2 to target writable");
		return this._stream.pipe(target);
	}
};

function __guard__(value, transform) {
	return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}
