'use strict'

// Extension to print the component + version that will be processed 

module.exports.register = function () {
  this.once('contentAggregated', ({ contentAggregate }) => {
    console.log('\nProcessing the following components and versions\n')
    const component_table = []
      contentAggregate.forEach((bucket) => {
        component_table.push ({Name: bucket.name, Version: bucket.version || '~', Files: bucket.files.length})
      })
    console.table(component_table)
    console.log() // do not delete, else we get a double empty line
  })
}
