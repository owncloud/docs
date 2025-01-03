var net = require('net');
var stream = require("stream");
var util = require('util');

function MyTransformStream(options) {
	stream.Transform.call(this, options);
}
util.inherits(MyTransformStream, stream.Transform);

MyTransformStream.prototype._transform = function _transform(chunk, encoding, callback) {
	console.log("Got chunk, length", chunk.length);
	this.push(chunk);
	return callback();
};

var transformStream = new MyTransformStream({
	highWaterMark: 200 * 102
});

transformStream.on('end', function onEnd() {
	console.log('Got end on transform stream!');
});

// Start reading on the transform stream so that
// the pipeline is kept flowing
//transformStream.on('data', function() {});

var server = net.createServer(function onConnection(socket) {
	// Make sure that libuv's loop is not kept alive by the server's handle
	server.unref();
	socket.pipe(transformStream);
});

server.listen(4242, function() {
	console.log('server listening...');
});
