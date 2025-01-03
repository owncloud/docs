"use strict"; // FIXME: Force-lowercase user-supplied headers before merging them into the request?
// FIXME: Deep-merge query-string arguments between URL and argument?
// FIXME: Named arrays for multipart/form-data?
// FIXME: Are arrays of streams in `data` correctly recognized as being streams?
// Core modules

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }

function _createForOfIteratorHelper(o, allowArrayLike) { var it; if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) { if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var normalCompletion = true, didErr = false, err; return { s: function s() { it = o[Symbol.iterator](); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it.return != null) it.return(); } finally { if (didErr) throw err; } } }; }

function _toConsumableArray(arr) { return _arrayWithoutHoles(arr) || _iterableToArray(arr) || _unsupportedIterableToArray(arr) || _nonIterableSpread(); }

function _nonIterableSpread() { throw new TypeError("Invalid attempt to spread non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); }

function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }

function _iterableToArray(iter) { if (typeof Symbol !== "undefined" && Symbol.iterator in Object(iter)) return Array.from(iter); }

function _arrayWithoutHoles(arr) { if (Array.isArray(arr)) return _arrayLikeToArray(arr); }

function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

var urlUtil = require("url");

var querystring = require("querystring");

var stream = require("stream");

var http = require("http");

var https = require("https"); // Utility modules


var Promise = require("bluebird");

var formFixArray = require("form-fix-array");

var errors = require("errors");

var debug = require("debug");

var debugRequest = debug("bhttp:request");
var debugResponse = debug("bhttp:response");

var extend = require("extend");

var devNull = require("dev-null");

var deepClone = require("lodash.clonedeep");

var deepMerge = require("lodash.merge"); // Other third-party modules


var formData = require("form-data2");

var concatStream = require("concat-stream");

var toughCookie = require("tough-cookie");

var streamLength = require("stream-length");

var sink = require("through2-sink");

var spy = require("through2-spy"); // For the version in the user agent, etc.


var packageConfig = require("../package.json");

var bhttpErrors = {}; // Error types

errors.create({
  name: "bhttpError",
  scope: bhttpErrors
});
errors.create({
  name: "ConflictingOptionsError",
  parents: bhttpErrors.bhttpError,
  scope: bhttpErrors
});
errors.create({
  name: "UnsupportedProtocolError",
  parents: bhttpErrors.bhttpError,
  scope: bhttpErrors
});
errors.create({
  name: "RedirectError",
  parents: bhttpErrors.bhttpError,
  scope: bhttpErrors
});
errors.create({
  name: "MultipartError",
  parents: bhttpErrors.bhttpError,
  scope: bhttpErrors
});
errors.create({
  name: "ConnectionTimeoutError",
  parents: bhttpErrors.bhttpError,
  scope: bhttpErrors
});
errors.create({
  name: "ResponseTimeoutError",
  parents: bhttpErrors.bhttpError,
  scope: bhttpErrors
}); // Utility functions

function shallowClone(object) {
  return Object.assign({}, object);
}

function iterateValues(object) {
  if (object == null) {
    return [];
  } else {
    return Object.values(object);
  }
}

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

var ofTypes = function ofTypes(obj, types) {
  var match = false;

  var _iterator = _createForOfIteratorHelper(types),
      _step;

  try {
    for (_iterator.s(); !(_step = _iterator.n()).done;) {
      var type = _step.value;
      match = match || obj instanceof type;
    }
  } catch (err) {
    _iterator.e(err);
  } finally {
    _iterator.f();
  }

  return match;
};

var isStream = function isStream(obj) {
  return obj != null && (ofTypes(obj, [stream.Readable, stream.Duplex, stream.Transform]) || obj.hasOwnProperty("_bhttpStreamWrapper"));
}; // Middleware
// NOTE: requestState is an object that signifies the current state of the overall request; eg. for a response involving one or more redirects, it will hold a 'redirect history'.


var prepareSession = function prepareSession(request, response, requestState) {
  debugRequest("preparing session");
  return Promise.try(function () {
    if (requestState.sessionOptions != null) {
      // Request options take priority over session options
      request.options = deepMerge(shallowClone(requestState.sessionOptions), request.options);
    } // Create a headers parameter if it doesn't exist yet - we'll need to add some stuff to this later on
    // FIXME: We may need to do a deep-clone of other mutable options later on as well; otherwise, when getting a redirect in a session with pre-defined options, the contents may not be correctly cleared after following the redirect.


    if (request.options.headers != null) {
      request.options.headers = deepClone(request.options.headers);
    } else {
      request.options.headers = {};
    } // If we have a cookie jar, start out by setting the cookie string.


    if (request.options.cookieJar != null) {
      return Promise.try(function () {
        // Move the cookieJar to the request object, the http/https module doesn't need it.
        request.cookieJar = request.options.cookieJar;
        delete request.options.cookieJar; // Get the current cookie string for the URL

        return request.cookieJar.get(request.url);
      }).then(function (cookieString) {
        debugRequest("sending cookie string: %s", cookieString);
        request.options.headers["cookie"] = cookieString;
        return Promise.resolve([request, response, requestState]);
      });
    } else {
      return Promise.resolve([request, response, requestState]);
    }
  });
};

var prepareDefaults = function prepareDefaults(request, response, requestState) {
  debugRequest("preparing defaults");
  return Promise.try(function () {
    // These are the options that we need for response processing, but don't need to be passed on to the http/https module.
    request.responseOptions = {
      discardResponse: request.options.discardResponse != null ? request.options.discardResponse : false,
      keepRedirectResponses: request.options.keepRedirectResponses != null ? request.options.keepRedirectResponses : false,
      followRedirects: request.options.followRedirects != null ? request.options.followRedirects : true,
      noDecode: request.options.noDecode != null ? request.options.noDecode : false,
      decodeJSON: request.options.decodeJSON != null ? request.options.decodeJSON : false,
      stream: request.options.stream != null ? request.options.stream : false,
      justPrepare: request.options.justPrepare != null ? request.options.justPrepare : false,
      redirectLimit: request.options.redirectLimit != null ? request.options.redirectLimit : 10,
      onDownloadProgress: request.options.onDownloadProgress,
      responseTimeout: request.options.responseTimeout
    }; // Whether chunked transfer encoding for multipart/form-data payloads is acceptable. This is likely to break quietly on a lot of servers.

    if (request.options.allowChunkedMultipart == null) {
      request.options.allowChunkedMultipart = false;
    } // Whether we should always use multipart/form-data for payloads, even if querystring-encoding would be a possibility.


    if (request.options.forceMultipart == null) {
      request.options.forceMultipart = false;
    } // If no custom user-agent is defined, set our own


    if (request.options.headers["user-agent"] == null) {
      request.options.headers["user-agent"] = "bhttp/".concat(packageConfig.version);
    } // Normalize the request method to lowercase.


    request.options.method = request.options.method.toLowerCase();
    return Promise.resolve([request, response, requestState]);
  });
};

var prepareUrl = function prepareUrl(request, response, requestState) {
  debugRequest("preparing URL");
  return Promise.try(function () {
    // Parse the specified URL, and use the resulting information to build a complete `options` object
    var urlOptions = urlUtil.parse(request.url, true);
    assign(request.options, {
      hostname: urlOptions.hostname,
      port: urlOptions.port
    });
    request.options.path = urlUtil.format({
      pathname: urlOptions.pathname,
      query: request.options.query != null ? request.options.query : urlOptions.query
    });
    request.protocol = urlOptions.protocol.replace(/:$/, "");
    return Promise.resolve([request, response, requestState]);
  });
};

var prepareProtocol = function prepareProtocol(request, response, requestState) {
  debugRequest("preparing protocol");
  return Promise.try(function () {
    request.protocolModule = function () {
      switch (request.protocol) {
        case "http":
          return http;

        case "https":
          return https;
        // CAUTION / FIXME: Node will silently ignore SSL settings without a custom agent!

        default:
          return null;
      }
    }();

    if (request.protocolModule == null) {
      return Promise.reject(new bhttpErrors.UnsupportedProtocolError("The protocol specified (".concat(request.protocol, ") is not currently supported by this module.")));
    }

    if (request.options.port == null) {
      request.options.port = function () {
        switch (request.protocol) {
          case "http":
            return 80;

          case "https":
            return 443;
        }
      }();
    }

    return Promise.resolve([request, response, requestState]);
  });
};

var prepareOptions = function prepareOptions(request, response, requestState) {
  debugRequest("preparing options");
  return Promise.try(function () {
    // Do some sanity checks - there are a number of options that cannot be used together
    if ((request.options.formFields != null || request.options.files != null) && (request.options.inputStream != null || request.options.inputBuffer != null)) {
      return Promise.reject(new bhttpErrors.ConflictingOptionsError({
        message: "You cannot define both formFields/files and a raw inputStream or inputBuffer.",
        request: request,
        response: response,
        requestState: requestState
      }));
    }

    if (request.options.encodeJSON && (request.options.inputStream != null || request.options.inputBuffer != null)) {
      var _bhttpErrors$Conflict;

      return Promise.reject(new bhttpErrors.ConflictingOptionsError((_bhttpErrors$Conflict = {
        message: "You cannot use both encodeJSON and a raw inputStream or inputBuffer.",
        response: "If you meant to JSON-encode the stream, you will currently have to do so manually.",
        request: request
      }, _defineProperty(_bhttpErrors$Conflict, "response", response), _defineProperty(_bhttpErrors$Conflict, "requestState", requestState), _bhttpErrors$Conflict)));
    } // If the user plans on streaming the response, we need to disable the agent entirely - otherwise the streams will block the pool.


    if (request.responseOptions.stream) {
      if (request.options.agent == null) {
        request.options.agent = false;
      }
    }

    return Promise.resolve([request, response, requestState]);
  });
};

var preparePayload = function preparePayload(request, response, requestState) {
  debugRequest("preparing payload");
  return Promise.try(function () {
    // Persist the download progress event handler on the request object, if there is one.
    request.onUploadProgress = request.options.onUploadProgress; // If a 'files' parameter is present, then we will send the form data as multipart data - it's most likely binary data.

    var multipart = request.options.forceMultipart || request.options.files != null; // Similarly, if any of the formFields values are either a Stream or a Buffer, we will assume that the form should be sent as multipart.

    multipart = multipart || iterateValues(request.options.formFields).some(function (item) {
      return item instanceof Buffer || isStream(item);
    }); // Really, 'files' and 'formFields' are the same thing - they mostly have different names for 1) clarity and 2) multipart detection. We combine them here.

    assign(request.options.formFields, request.options.files); // For a last sanity check, we want to know whether there are any Stream objects in our form data *at all* - these can't be used when encodeJSON is enabled.

    var containsStreams = iterateValues(request.options.formFields).some(function (item) {
      return isStream(item);
    });

    if (request.options.encodeJSON && containsStreams) {
      return Promise.reject(new bhttpErrors.ConflictingOptionsError("Sending a JSON-encoded payload containing data from a stream is not currently supported.", undefined, "Either don't use encodeJSON, or read your stream into a string or Buffer."));
    }

    if (!["get", "head", "delete"].includes(request.options.method)) {
      // Prepare the payload, and set the appropriate headers.
      if ((request.options.encodeJSON || request.options.formFields != null) && !multipart) {
        // We know the payload and its size in advance.
        debugRequest("got url-encodable form-data");

        if (request.options.encodeJSON) {
          debugRequest("... but encodeJSON was set, so we will send JSON instead");
          request.options.headers["content-type"] = "application/json";
          request.payload = JSON.stringify(request.options.formFields != null ? request.options.formFields : null);
        } else if (Object.keys(request.options.formFields).length > 0) {
          // The `querystring` module copies the key name verbatim, even if the value is actually an array. Things like PHP don't understand this, and expect every array-containing key to be suffixed with []. We'll just append that ourselves, then.
          request.options.headers["content-type"] = "application/x-www-form-urlencoded";
          request.payload = querystring.stringify(formFixArray(request.options.formFields));
        } else {
          request.payload = "";
        }

        request.options.headers["content-length"] = request.payload.length;
        return Promise.resolve();
      } else if (request.options.formFields != null && multipart) {
        // This is going to be multipart data, and we'll let `form-data` set the headers for us.
        debugRequest("got multipart form-data");
        var formDataObject = new formData();
        var object = formFixArray(request.options.formFields);

        for (var fieldName in object) {
          var fieldValue = object[fieldName];

          if (!Array.isArray(fieldValue)) {
            fieldValue = [fieldValue];
          }

          var _iterator2 = _createForOfIteratorHelper(fieldValue),
              _step2;

          try {
            for (_iterator2.s(); !(_step2 = _iterator2.n()).done;) {
              var valueElement = _step2.value;
              var streamOptions;

              if (valueElement._bhttpStreamWrapper != null) {
                streamOptions = valueElement.options;
                valueElement = valueElement.stream;
              } else {
                streamOptions = {};
              }

              formDataObject.append(fieldName, valueElement, streamOptions);
            }
          } catch (err) {
            _iterator2.e(err);
          } finally {
            _iterator2.f();
          }
        }

        request.payloadStream = formDataObject;
        return Promise.try(function () {
          return formDataObject.getHeaders();
        }).then(function (headers) {
          if (headers["content-transfer-encoding"] === "chunked" && !request.options.allowChunkedMultipart) {
            return Promise.reject(new bhttpErrors.MultipartError({
              message: "Most servers do not support chunked transfer encoding for multipart/form-data payloads, and we could not determine the length of all the input streams. See the documentation for more information.",
              request: request,
              response: response,
              requestState: requestState
            }));
          } else {
            assign(request.options.headers, headers);
            return Promise.resolve();
          }
        });
      } else if (request.options.inputStream != null) {
        // A raw inputStream was provided, just leave it be.
        debugRequest("got inputStream");
        return Promise.try(function () {
          request.payloadStream = request.options.inputStream;

          if (request.payloadStream._bhttpStreamWrapper != null && (request.payloadStream.options.contentLength != null || request.payloadStream.options.knownLength != null)) {
            return Promise.resolve(request.payloadStream.options.contentLength != null ? request.payloadStream.options.contentLength : request.payloadStream.options.knownLength);
          } else {
            return streamLength(request.options.inputStream);
          }
        }).then(function (length) {
          debugRequest("length for inputStream is %s", length);
          request.options.headers["content-length"] = length;
        }).catch(function (_error) {
          debugRequest("unable to determine inputStream length, switching to chunked transfer encoding");
          request.options.headers["content-transfer-encoding"] = "chunked";
        });
      } else if (request.options.inputBuffer != null) {
        // A raw inputBuffer was provided, just leave it be (but make sure it's an actual Buffer).
        debugRequest("got inputBuffer");

        if (typeof request.options.inputBuffer === "string") {
          request.payload = new Buffer(request.options.inputBuffer); // Input string should be utf-8!
        } else {
          request.payload = request.options.inputBuffer;
        }

        debugRequest("length for inputBuffer is %s", request.payload.length);
        request.options.headers["content-length"] = request.payload.length;
        return Promise.resolve();
      } else {
        // No payload specified.
        return Promise.resolve();
      }
    } else {
      // GET, HEAD and DELETE should not have a payload. While technically not prohibited by the spec, it's also not specified, and we'd rather not upset poorly-compliant webservers.
      // FIXME: Should this throw an Error?
      return Promise.resolve();
    }
  }).then(function () {
    return Promise.resolve([request, response, requestState]);
  });
};

var prepareCleanup = function prepareCleanup(request, response, requestState) {
  debugRequest("preparing cleanup");
  return Promise.try(function () {
    // Remove the options that we're not going to pass on to the actual http/https library.
    var key;

    for (var _i = 0, _arr = ["query", "formFields", "files", "encodeJSON", "inputStream", "inputBuffer", "discardResponse", "keepRedirectResponses", "followRedirects", "noDecode", "decodeJSON", "allowChunkedMultipart", "forceMultipart", "onUploadProgress", "onDownloadProgress"]; _i < _arr.length; _i++) {
      key = _arr[_i];
      delete request.options[key];
    } // Lo-Dash apparently has no `map` equivalent for object keys...?


    var fixedHeaders = {};

    for (key in request.options.headers) {
      var value = request.options.headers[key];
      fixedHeaders[key.toLowerCase()] = value;
    }

    request.options.headers = fixedHeaders;
    return Promise.resolve([request, response, requestState]);
  });
}; // The guts of the module


var prepareRequest = function prepareRequest(request, response, requestState) {
  debugRequest("preparing request"); // FIXME: Mock httpd for testing functionality.

  return Promise.try(function () {
    var middlewareFunctions = [prepareSession, prepareDefaults, prepareUrl, prepareProtocol, prepareOptions, preparePayload, prepareCleanup];
    var promiseChain = Promise.resolve([request, response, requestState]);
    middlewareFunctions.forEach(function (middleware) {
      // We must use the functional construct here, to avoid losing references
      promiseChain = promiseChain.spread(function (_request, _response, _requestState) {
        return middleware(_request, _response, _requestState);
      });
    });
    return promiseChain;
  });
};

var makeRequest = function makeRequest(request, response, requestState) {
  debugRequest("making %s request to %s", request.options.method.toUpperCase(), request.url);
  return Promise.try(function () {
    // Instantiate a regular HTTP/HTTPS request
    var req = request.protocolModule.request(request.options);
    var timeoutTimer = null;
    return new Promise(function (resolve, reject) {
      // Connection timeout handling, if one is set.
      if (request.responseOptions.responseTimeout != null) {
        debugRequest("setting response timeout timer to ".concat(request.responseOptions.responseTimeout, "ms..."));
        req.on("socket", function (_socket) {
          var timeoutHandler = function timeoutHandler() {
            debugRequest("a response timeout occurred!");
            req.abort();
            return reject(new bhttpErrors.ResponseTimeoutError("The response timed out."));
          };

          timeoutTimer = setTimeout(timeoutHandler, request.responseOptions.responseTimeout);
        });
      } // Set up the upload progress monitoring.


      var totalBytes = request.options.headers["content-length"];
      var completedBytes = 0;
      var progressStream = spy(function (chunk) {
        completedBytes += chunk.length;
        return req.emit("progress", completedBytes, totalBytes);
      });

      if (request.onUploadProgress != null) {
        req.on("progress", function (completedBytes, totalBytes) {
          return request.onUploadProgress(completedBytes, totalBytes, req);
        });
      } // This is where we write our payload or stream to the request, and the actual request is made.


      if (request.payload != null) {
        // The entire payload is a single Buffer. We'll still pretend that it's a stream for our progress events, though, to provide a consistent API.
        debugRequest("sending payload");
        req.emit("progress", request.payload.length, request.payload.length);
        req.write(request.payload);
        req.end();
      } else if (request.payloadStream != null) {
        // The payload is a stream.
        debugRequest("piping payloadStream");

        if (request.payloadStream._bhttpStreamWrapper != null) {
          request.payloadStream.stream.pipe(progressStream).pipe(req);
        } else {
          request.payloadStream.pipe(progressStream).pipe(req);
        }
      } else {
        // For GET, HEAD, DELETE, etc. there is no payload, but we still need to call end() to complete the request.
        debugRequest("closing request without payload");
        req.end();
      } // In case something goes wrong during this process, somehow...


      req.on("error", function (err) {
        if (err.code === "ETIMEDOUT") {
          debugRequest("a connection timeout occurred!");
          return reject(new bhttpErrors.ConnectionTimeoutError("The connection timed out."));
        } else {
          return reject(err);
        }
      });
      return req.on("response", function (res) {
        if (timeoutTimer != null) {
          debugResponse("got response in time, clearing response timeout timer");
          clearTimeout(timeoutTimer);
        }

        return resolve(res);
      });
    });
  }).then(function (response) {
    return Promise.resolve([request, response, requestState]);
  });
};

var processResponse = function processResponse(request, response, requestState) {
  debugResponse("processing response, got status code %s", response.statusCode); // When we receive the response, we'll buffer it up and/or decode it, depending on what the user specified, and resolve the returned Promise. If the user just wants the raw stream, we resolve immediately after receiving a response.

  return Promise.try(function () {
    // First, if a cookie jar is set and we received one or more cookies from the server, we should store them in our cookieJar.
    if (request.cookieJar != null && response.headers["set-cookie"] != null) {
      var promises = function () {
        var result = [];

        var _iterator3 = _createForOfIteratorHelper(response.headers["set-cookie"]),
            _step3;

        try {
          for (_iterator3.s(); !(_step3 = _iterator3.n()).done;) {
            var cookieHeader = _step3.value;
            debugResponse("storing cookie: %s", cookieHeader);
            result.push(request.cookieJar.set(cookieHeader, request.url));
          }
        } catch (err) {
          _iterator3.e(err);
        } finally {
          _iterator3.f();
        }

        return result;
      }();

      return Promise.all(promises);
    } else {
      return Promise.resolve();
    }
  }).then(function () {
    // Now the actual response processing.
    response.request = request;
    response.requestState = requestState;
    response.redirectHistory = requestState.redirectHistory;

    if ([301, 302, 303, 307].includes(response.statusCode) && request.responseOptions.followRedirects) {
      if (requestState.redirectHistory.length >= request.responseOptions.redirectLimit - 1) {
        return Promise.reject(new bhttpErrors.RedirectError("The maximum amount of redirects ({request.responseOptions.redirectLimit}) was reached."));
      } // 301: For GET and HEAD, redirect unchanged. For POST, PUT, PATCH, DELETE, "ask user" (in our case: throw an error.)
      // 302: Redirect, change method to GET.
      // 303: Redirect, change method to GET.
      // 307: Redirect, retain method. Make same request again.


      switch (response.statusCode) {
        case 301:
          switch (request.options.method) {
            case "get":
            case "head":
              return redirectUnchanged(request, response, requestState);

            case "post":
            case "put":
            case "patch":
            case "delete":
              return Promise.reject(new bhttpErrors.RedirectError({
                message: "Encountered a 301 redirect for POST, PUT, PATCH or DELETE. RFC says we can't automatically continue.",
                request: request,
                response: response,
                requestState: requestState
              }));

            default:
              return Promise.reject(new bhttpErrors.RedirectError("Encountered a 301 redirect, but not sure how to proceed for the ".concat(request.options.method.toUpperCase(), " method.")));
          }

        case 302:
        case 303:
          return redirectGet(request, response, requestState);

        case 307:
          if (request.containsStreams && !["get", "head"].includes(request.options.method)) {
            return Promise.reject(new bhttpErrors.RedirectError({
              message: "Encountered a 307 redirect for POST, PUT or DELETE, but your payload contained (single-use) streams. We therefore can't automatically follow the redirect.",
              request: request,
              response: response,
              requestState: requestState
            }));
          } else {
            return redirectUnchanged(request, response, requestState);
          }

      }
    } else if (request.responseOptions.discardResponse) {
      response.pipe(devNull()); // Drain the response stream

      return Promise.resolve(response);
    } else {
      var totalBytes = response.headers["content-length"];

      if (totalBytes != null) {
        // Otherwise `undefined` will turn into `NaN`, and we don't want that.
        totalBytes = parseInt(totalBytes);
      }

      var completedBytes = 0;
      var progressStream = sink(function (chunk) {
        completedBytes += chunk.length;
        return response.emit("progress", completedBytes, totalBytes);
      });

      if (request.responseOptions.onDownloadProgress != null) {
        response.on("progress", function (completedBytes, totalBytes) {
          return request.responseOptions.onDownloadProgress(completedBytes, totalBytes, response);
        });
      }

      return new Promise(function (resolve, reject) {
        // This is a very, very dirty hack - however, using .pipe followed by .pause breaks in Node.js v0.10.35 with "Cannot switch to old mode now". Our solution is to monkeypatch the `on` and `resume` methods to attach the progress event handler as soon as something else is attached to the response stream (or when it is drained). This way, a user can also pipe the response in a later tick, without the stream draining prematurely.
        var _resume = response.resume.bind(response);

        var _on = response.on.bind(response);

        var _progressStreamAttached = false;

        var attachProgressStream = function attachProgressStream() {
          // To keep this from sending us into an infinite loop.
          if (!_progressStreamAttached) {
            debugResponse("attaching progress stream");
            _progressStreamAttached = true;
            return response.pipe(progressStream);
          }
        };

        response.on = function (eventName, handler) {
          debugResponse("'on' called, ".concat(eventName));

          if (eventName === "data" || eventName === "readable") {
            attachProgressStream();
          }

          return _on(eventName, handler);
        };

        response.resume = function () {
          attachProgressStream();
          return _resume();
        }; // Continue with the regular response processing.


        if (request.responseOptions.stream) {
          return resolve(response);
        } else {
          response.on("error", function (err) {
            return reject(err);
          });
          return response.pipe(concatStream(function (body) {
            // FIXME: Separate module for header parsing?
            if (request.responseOptions.decodeJSON || (response.headers["content-type"] != null ? response.headers["content-type"] : "").split(";")[0] === "application/json" && !request.responseOptions.noDecode) {
              try {
                response.body = JSON.parse(body);
              } catch (err) {
                reject(err);
              }
            } else {
              response.body = body;
            }

            return resolve(response);
          }));
        }
      });
    }
  }).then(function (response) {
    return Promise.resolve([request, response, requestState]);
  });
}; // Some wrappers


var doPayloadRequest = function doPayloadRequest(url, data, options, callback) {
  // A wrapper that processes the second argument to .post, .put, .patch shorthand API methods.
  // FIXME: Treat a {} for data as a null? Otherwise {} combined with inputBuffer/inputStream will error.
  if (isStream(data)) {
    options.inputStream = data;
  } else if (ofTypes(data, [Buffer]) || typeof data === "string") {
    options.inputBuffer = data;
  } else {
    options.formFields = data;
  }

  return this.request(url, options, callback);
};

var redirectGet = function redirectGet(request, response, requestState) {
  debugResponse("following forced-GET redirect to %s", response.headers["location"]);
  return Promise.try(function () {
    var options = shallowClone(requestState.originalOptions);
    options.method = "get";

    for (var _i2 = 0, _arr2 = ["inputBuffer", "inputStream", "files", "formFields"]; _i2 < _arr2.length; _i2++) {
      var key = _arr2[_i2];
      delete options[key];
    }

    return doRedirect(request, response, requestState, options);
  });
};

var redirectUnchanged = function redirectUnchanged(request, response, requestState) {
  debugResponse("following same-method redirect to %s", response.headers["location"]);
  return Promise.try(function () {
    var options = shallowClone(requestState.originalOptions);
    return doRedirect(request, response, requestState, options);
  });
};

var doRedirect = function doRedirect(request, response, requestState, newOptions) {
  return Promise.try(function () {
    if (!request.responseOptions.keepRedirectResponses) {
      response.pipe(devNull()); // Let the response stream drain out...
    }

    requestState.redirectHistory.push(response);
    return bhttpAPI._doRequest(urlUtil.resolve(request.url, response.headers["location"]), newOptions, requestState);
  });
};

var createCookieJar = function createCookieJar(jar) {
  // Creates a cookie jar wrapper with a simplified API.
  return {
    set: function set(cookie, url) {
      var _this = this;

      return new Promise(function (resolve, reject) {
        return _this.jar.setCookie(cookie, url, function (err, cookie) {
          if (err) {
            return reject(err);
          } else {
            return resolve(cookie);
          }
        });
      });
    },
    get: function get(url) {
      var _this2 = this;

      return new Promise(function (resolve, reject) {
        return _this2.jar.getCookieString(url, function (err, cookies) {
          if (err) {
            return reject(err);
          } else {
            return resolve(cookies);
          }
        });
      });
    },
    jar: jar
  };
}; // The exposed API


var bhttpAPI = {
  head: function head(url, options, callback) {
    if (options == null) {
      options = {};
    }

    options.method = "head";
    return this.request(url, options, callback);
  },
  get: function get(url, options, callback) {
    if (options == null) {
      options = {};
    }

    options.method = "get";
    return this.request(url, options, callback);
  },
  post: function post(url, data, options, callback) {
    if (options == null) {
      options = {};
    }

    options.method = "post";
    return doPayloadRequest.bind(this)(url, data, options, callback);
  },
  put: function put(url, data, options, callback) {
    if (options == null) {
      options = {};
    }

    options.method = "put";
    return doPayloadRequest.bind(this)(url, data, options, callback);
  },
  patch: function patch(url, data, options, callback) {
    if (options == null) {
      options = {};
    }

    options.method = "patch";
    return doPayloadRequest.bind(this)(url, data, options, callback);
  },
  delete: function _delete(url, options, callback) {
    if (options == null) {
      options = {};
    }

    options.method = "delete";
    return this.request(url, options, callback);
  },
  request: function request(url, options, callback) {
    if (options == null) {
      options = {};
    }

    return this._doRequest(url, options).nodeify(callback);
  },
  _doRequest: function _doRequest(url, options, requestState) {
    var _this3 = this;

    // This is split from the `request` method, so that the user doesn't have to pass in `undefined` for the `requestState` when they want to specify a `callback`.
    return Promise.try(function () {
      var request = {
        url: url,
        options: shallowClone(options)
      };
      var response = null;

      if (requestState == null) {
        requestState = {
          originalOptions: shallowClone(options),
          redirectHistory: []
        };
      }

      if (requestState.sessionOptions == null) {
        requestState.sessionOptions = _this3._sessionOptions != null ? _this3._sessionOptions : {};
      }

      return prepareRequest(request, response, requestState);
    }).spread(function (request, response, requestState) {
      if (request.responseOptions.justPrepare) {
        return Promise.resolve([request, response, requestState]);
      } else {
        return Promise.try(function () {
          return bhttpAPI.executeRequest(request, response, requestState);
        }).spread(function (request, response, _requestState) {
          // The user likely only wants the response.
          return Promise.resolve(response);
        });
      }
    });
  },
  executeRequest: function executeRequest(request, response, requestState) {
    // Executes a pre-configured request.
    return Promise.try(function () {
      return makeRequest(request, response, requestState);
    }).spread(function (request, response, requestState) {
      return processResponse(request, response, requestState);
    });
  },
  session: function session(options) {
    if (options == null) {
      options = {};
    }

    options = shallowClone(options);
    var session = {};

    for (var key in this) {
      var value = this[key];

      if (value instanceof Function) {
        value = value.bind(session);
      }

      session[key] = value;
    }

    if (options.cookieJar == null) {
      options.cookieJar = createCookieJar(new toughCookie.CookieJar());
    } else if (options.cookieJar === false) {
      delete options.cookieJar;
    } else {
      // Assume we've gotten a cookie jar.
      options.cookieJar = createCookieJar(options.cookieJar);
    }

    session._sessionOptions = options;
    return session;
  },
  wrapStream: function wrapStream(stream, options) {
    // This is a method for wrapping a stream in an object that also contains metadata.
    return {
      _bhttpStreamWrapper: true,
      stream: stream,
      options: options
    };
  }
};
extend(bhttpAPI, bhttpErrors);
module.exports = bhttpAPI; // That's all, folks!
