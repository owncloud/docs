fs = require "fs"
stream = require "stream"

transform = new stream.Transform(highWaterMark: 200 * 1024)
transform._transform = (chunk, encoding, callback) ->
	console.log "Got chunk, length", chunk.length
	@push chunk
	callback()

console.log "Starting stream..."
fs.createReadStream "./lower.txt"
	.pipe transform
	.on "end", ->
		console.log "Done!"
