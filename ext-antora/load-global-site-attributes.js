// v1.0.0
"use strict"

const fs    = require('fs')
const http  = require('http')
const https = require('https')
const yaml  = require('js-yaml')

// this extension loads (global) attributes into the playbook (site.yml)
// !! attributes in the playbook take precedence over loaded attributes !!
// allows test building a repo like in multi repo envs with custom local attribute values
// you can temporarily disable loading by setting 'enabled: false'
// error handling:
//   if no 'attributefile' is configured: warn, but continue processing
//   if loading or processing the file caused an error (like file not found, needs fixing): stop

module.exports.register = function ({ config }) {
    const logger = this.getLogger('load-global-site-attributes-extension')
    let attrib_file   = ''
    let attrib_yaml   = {}
    let orig_playbook = {}
    let result        = {}

    this.on("playbookBuilt", async ({ playbook }) => {
      // get the original playbook asciidoc attributes, note it can be empty
      orig_playbook = JSON.parse(JSON.stringify(playbook.asciidoc.attributes)) || {}

      // only if attributefile is configured in site.yml pointing to a resource (file or url)
      if (config.attributefile) {
        try {
          // define the get function to use and load the file
          if (config.attributefile.startsWith('http')) {
            attrib_file = await get_file_from_url(config.attributefile)
          } else {
            attrib_file = await get_file_from_local(config.attributefile)
          }

          // convert and update
          attrib_yaml = await convert_yaml(attrib_file)
          result = Object.assign(attrib_yaml, playbook.asciidoc.attributes)
          playbook.asciidoc.attributes = result
          this.updateVariables( playbook )

        // loading or processing the file caused an error
        } catch (error) {
            logger.error(error)
            this.stop()
        }
      } else {
        logger.warn('attributefile is not configured in the playbook (site.yml).')
      }
//      console.log(this.getVariables())
    })
}

function get_file_from_url(url) {
    // promise a file from url
    // when executed it returns the contents if found
    return new Promise((resolve, reject) => {
      const client = url.startsWith('https') ? https : http
      const req = client.request(url, (res) => {
        if (res.statusCode < 200 || res.statusCode >= 300) {
              reject(`Request Failed.\n` +
                     `Status Code: ${res.statusCode}\n` +
                     `${url}`)
          }
          var body = []
          res.on('data', function(chunk) {
              body.push(chunk)
          })
          res.on('end', function() {
              try {
                  body = Buffer.concat(body).toString()
              } catch(error) {
                  reject(error)
              }
              resolve(body)
          })
      })
      req.on('error', (error) => {
        reject(error.message)
      })
      // send the request
      req.end()
    })
}

function get_file_from_local(file) {
    // promise a file from local filesystem
    // when executed it returns the contents if found
    return new Promise((resolve, reject) => {
      fs.readFile(file, 'utf8', (error, data) => {
        if (error) reject(error)
        resolve(data)
      })
    })
}

function convert_yaml(data) {
    // promise to parse yaml data
    // when executed it returns the parsed contents
    return new Promise((resolve, reject) => {
      try {
        var d = yaml.load(data)
      // the parser found an error, no object will be returned
      } catch (error) {
        reject(`yaml parser: ` + error)
      }
      resolve(d)
    })
}
