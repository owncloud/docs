'use strict'

// Extension to print the component + version that will be processed 

module.exports.register = function () {
  this.once('contentAggregated', ({ contentAggregate }) => {
    console.log('\nProcessing the following components and versions\n')
    contentAggregate.forEach((bucket) => {
      console.log(`name: ${bucket.name}, version: ${bucket.version || '~'}, files: ${bucket.files.length}`)
    })
    console.log() // do not delete, else we get a double empty line
  })
}

