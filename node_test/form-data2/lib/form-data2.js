"use strict"; // Standard library

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _toConsumableArray(arr) { return _arrayWithoutHoles(arr) || _iterableToArray(arr) || _nonIterableSpread(); }

function _nonIterableSpread() { throw new TypeError("Invalid attempt to spread non-iterable instance"); }

function _iterableToArray(iter) { if (Symbol.iterator in Object(iter) || Object.prototype.toString.call(iter) === "[object Arguments]") return Array.from(iter); }

function _arrayWithoutHoles(arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = new Array(arr.length); i < arr.length; i++) { arr2[i] = arr[i]; } return arr2; } }

var path = require("path");

var stream = require("stream"); // Third-party dependencies


var uuid = require("uuid");

var mime = require("mime");

var combinedStream2 = require("combined-stream2");

var Promise = require("bluebird");

var debug = require("debug")("form-data2");

var CRLF = "\r\n"; // Utility functions

var ofTypes = function ofTypes(obj, types) {
  var match = false;
  var _iteratorNormalCompletion = true;
  var _didIteratorError = false;
  var _iteratorError = undefined;

  try {
    for (var _iterator = types[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
      var type = _step.value;
      match = match || obj instanceof type;
    }
  } catch (err) {
    _didIteratorError = true;
    _iteratorError = err;
  } finally {
    try {
      if (!_iteratorNormalCompletion && _iterator.return != null) {
        _iterator.return();
      }
    } finally {
      if (_didIteratorError) {
        throw _iteratorError;
      }
    }
  }

  return match;
};

function assign() {
  for (var _len = arguments.length, objects = new Array(_len), _key = 0; _key < _len; _key++) {
    objects[_key] = arguments[_key];
  }

  var validObjects = objects.filter(function (object) {
    return object != null;
  });

  if (validObjects.length === 0) {
    return {};
  } else if (validObjects.length === 1) {
    return validObjects[0];
  } else {
    return Object.assign.apply(Object, _toConsumableArray(validObjects));
  }
}

module.exports =
/*#__PURE__*/
function () {
  function FormData() {
    _classCallCheck(this, FormData);

    this._firstHeader = false;
    this._closingHeaderAppended = false;
    this._boundary = "----" + uuid.v4();
    this._headers = {
      "content-type": "multipart/form-data; boundary=".concat(this._boundary)
    };
    this._stream = combinedStream2.create();
  }

  _createClass(FormData, [{
    key: "_getStreamMetadata",
    value: function _getStreamMetadata(source, options) {
      // FIXME: Make work with deferred sources (ie. callback-provided)
      var contentLength, contentType, filename, left;
      debug("obtaining metadata for source: %s", source.toString().replace(/\n/g, "\\n").replace(/\r/g, "\\r"));
      var fullPath = (left = options.filename != null ? options.filename : __guard__(source.client != null ? source.client._httpMessage : undefined, function (x) {
        return x.path;
      })) != null ? left : source.path;

      if (fullPath != null) {
        // This is a file...
        var left1, left2;
        filename = path.basename(fullPath);
        contentType = (left1 = options.contentType != null ? options.contentType : source.headers != null ? source.headers["content-type"] : undefined) != null ? left1 : mime.lookup(filename);
        contentLength = (left2 = options.knownLength != null ? options.knownLength : options.contentLength) != null ? left2 : source.headers != null ? source.headers["content-length"] : undefined; // FIXME: Is this even used anywhere?
      } else {
        // Probably just a plaintext form value, or an unidentified stream
        var left3;
        contentType = options.contentType != null ? options.contentType : source.headers != null ? source.headers["content-type"] : undefined;
        contentLength = (left3 = options.knownLength != null ? options.knownLength : options.contentLength) != null ? left3 : source.headers != null ? source.headers["content-length"] : undefined;
      }

      return {
        filename: filename,
        contentType: contentType,
        contentLength: contentLength
      };
    }
  }, {
    key: "_generateHeaderFields",
    value: function _generateHeaderFields(name, metadata) {
      debug("generating headers for: %s", metadata);
      var headerFields = [];

      if (metadata.filename != null) {
        var escapedFilename = metadata.filename.replace('"', '\\"');
        headerFields.push("Content-Disposition: form-data; name=\"".concat(name, "\"; filename=\"").concat(escapedFilename, "\""));
      } else {
        headerFields.push("Content-Disposition: form-data; name=\"".concat(name, "\""));
      }

      if (metadata.contentType != null) {
        headerFields.push("Content-Type: ".concat(metadata.contentType));
      }

      debug("generated headers: %s", headerFields);
      return headerFields.join(CRLF);
    }
  }, {
    key: "_appendHeader",
    value: function _appendHeader(name, metadata) {
      var leadingCRLF;

      if (this._firstHeader === false) {
        debug("appending header");
        leadingCRLF = "";
        this._firstHeader = true;
      } else {
        debug("appending first header");
        leadingCRLF = CRLF;
      }

      var headerFields = this._generateHeaderFields(name, metadata);

      return this._stream.append(new Buffer(leadingCRLF + "--".concat(this._boundary) + CRLF + headerFields + CRLF + CRLF));
    }
  }, {
    key: "_appendClosingHeader",
    value: function _appendClosingHeader() {
      debug("appending closing header");
      return this._stream.append(new Buffer(CRLF + "--".concat(this._boundary, "--")));
    }
  }, {
    key: "append",
    value: function append(name, source, options) {
      if (options == null) {
        options = {};
      }

      debug("appending source");

      if (this._closingHeaderAppended) {
        throw new Error("The stream has already been prepared for usage; you either piped it or generated the HTTP headers. No new sources can be appended anymore.");
      }

      if (!ofTypes(source, [stream.Readable, stream.Duplex, stream.Transform, Buffer, Function]) && typeof source !== "string") {
        throw new Error("The provided value must be either a readable stream, a Buffer, a callback providing either of those, or a string.");
      }

      if (typeof source === "string") {
        source = new Buffer(source); // If the string isn't UTF-8, this won't end well!

        if (options.contentType == null) {
          options.contentType = "text/plain";
        }
      }

      var metadata = this._getStreamMetadata(source, options);

      this._appendHeader(name, metadata);

      return this._stream.append(source, options);
    }
  }, {
    key: "done",
    value: function done() {
      // This method should be called when the user is finished adding streams. It adds the termination header at the end of the combined stream. When piping, this method is automatically called!
      debug("called 'done'");

      if (!this._closingHeaderAppended) {
        this._closingHeaderAppended = true;
        return this._appendClosingHeader();
      }
    }
  }, {
    key: "getBoundary",
    value: function getBoundary() {
      return this._boundary;
    }
  }, {
    key: "getHeaders",
    value: function getHeaders(callback) {
      var _this = this;

      // Returns the headers needed to correctly transmit the generated multipart/form-data blob. We will first need to call @done() to make sure that the multipart footer is there - from this point on, no new sources can be appended anymore.
      this.done();
      return Promise.try(function () {
        return _this._stream.getCombinedStreamLength();
      }).then(function (length) {
        debug("total combined stream length: %s", length);
        return Promise.resolve({
          "content-length": length
        });
      }).catch(function (_error) {
        // We couldn't get the stream length, most likely there was a stream involved that `stream-length` does not support.
        debug("WARN: could not get total combined stream length");
        return Promise.resolve({
          "transfer-encoding": "chunked"
        });
      }).then(function (sizeHeaders) {
        return Promise.resolve(assign(sizeHeaders, _this._headers));
      }).nodeify(callback);
    }
  }, {
    key: "getLength",
    value: function getLength(callback) {
      return this._stream.getCombinedStreamLength(callback);
    }
  }, {
    key: "pipe",
    value: function pipe(target) {
      this.done(); // Pass through to the underlying `combined-stream`.

      debug("piping underlying combined-stream2 to target writable");
      return this._stream.pipe(target);
    }
  }]);

  return FormData;
}();

function __guard__(value, transform) {
  return typeof value !== 'undefined' && value !== null ? transform(value) : undefined;
}
