'use strict'

/**
 * Print a table of Component - Version - Number of Files + total.
 * Only the number of files in the modules directory are counted
 * Version 1.1.0
 *
 * ┌─────────┬────────┬─────────┬───────┐
 * │ (index) │  Name  │ Version │ Files │
 * ├─────────┼────────┼─────────┼───────┤
 * │    0    │ 'ROOT' │   '~'   │  14   │
 * │    3    │        │         │  14   │
 * └─────────┴────────┴─────────┴───────┘
 */
 
module.exports.register = function () {
  this.once('contentAggregated', ({ contentAggregate }) => {
    console.log('\nProcessing the following components, versions and number of files\n')
    var total_files = 0
    const component_table = []
      contentAggregate.forEach((bucket) => {
        var count = 0
        bucket.files.forEach((file) => {
          if (file.src.path.startsWith('modules')) {
            count += 1
          }
        })
        component_table.push ({Name: bucket.name, Version: bucket.version || '~', Files: count})
        total_files += count
      })
    component_table.push ({Files: total_files})
    console.table(component_table)
    console.log() // do not delete, else we get a double empty line
  })
}
