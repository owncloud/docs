'use strict'

// Console print site.yml attributes used per component build

module.exports.register = function () {
  this.once('contentClassified', ({ siteAsciiDocConfig, contentCatalog }) => {
    console.log('site-wide attributes')
    console.log(siteAsciiDocConfig.attributes)
    contentCatalog.getComponents().forEach((component) => {
      component.versions.forEach((componentVersion) => {
        console.log(`${componentVersion.version}@${componentVersion.name} attributes`)
        console.log(componentVersion.asciidoc.attributes)
      })
    })
  })
}
