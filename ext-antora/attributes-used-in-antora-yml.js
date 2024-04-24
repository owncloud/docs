'use strict'

// Console print antora.yml attributes used per component

module.exports.register = function () {
  this.once('contentClassified', ({ playbook, contentCatalog }) => {
    console.log('antora-playbook.yml attributes')
    console.log(playbook.asciidoc.attributes)
    contentCatalog.getComponents().forEach((component) => {
      component.versions.forEach((componentVersion) => {
        getUniqueOrigins(contentCatalog, componentVersion).forEach((origin) => {
          console.log(`antora.yml attributes (${componentVersion.version}@${componentVersion.name})`)
          console.log(origin.descriptor.asciidoc?.attributes || {})
        })
      })
    })
  })
}

function getUniqueOrigins (contentCatalog, componentVersion) {
  return contentCatalog.findBy({ component: componentVersion.name, version: componentVersion.version }).reduce((origins, file) => {
    const origin = file.src.origin
    if (origin && !origins.includes(origin)) origins.push(origin)
    return origins
  }, [])
}
