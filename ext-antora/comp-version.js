'use strict'

// Extension to print the component, version and number of files that will be processed 

module.exports.register = function () {
  this.once('contentAggregated', ({ contentAggregate }) => {
    console.log('\nProcessing the following components, versions and number of files\n')
    var total_files = 0
    const component_table = []
      contentAggregate.forEach((bucket) => {
        component_table.push ({Name: bucket.name, Version: bucket.version || '~', Files: bucket.files.length})
        total_files += parseInt(bucket.files.length)
      })
    component_table.length++
    component_table.length++
    component_table.push ({Files: total_files})
    console.table(component_table)
    console.log() // do not delete, else we get a double empty line
  })
}
