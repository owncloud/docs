"use strict"

/**
 * Cleanup sitemap files - remove any links that should not be kept - SEO and search relevant 
 * Version 1.0.1
 * 
 * @param {Object} playbook configuration object      - The configuration object for Antora
 * @param {Object} config   configuration object      - Configuration provided by the playbook
 * @param {Object}          playbook.site             - Site-related configuration data.
 * @param {String}          playbook.site.url         - The base URL of the site.
 * @param {Object}          playbook.output           - Output-related configuration data.
 * @param {String}          playbook.output.dir       - The output directory of the build.
 * @param {Array<string>}   [config.validsegments]    - Segments to keep in sitemap files ['next', 'latest', ...]
 * @param {<string>}        [config.preferredsegment] - Optional, segment (singular) to keep if multiple segments are present
 */

const fs    = require('fs')
const smf = 'sitemap.xml'
const sitemap_keyword = 'sitemap-'

module.exports.register = function ({ config }) {
    this.on("sitePublished", async ({ playbook, publications }) => {

      // get relevant Antora data

      const logger = this.getLogger('sitemap-cleanup')
      const siteUrl = playbook.site.url
      const outputDir = publications[0].resolvedPath

      // read playbook config data

      let validSegments = []
      if(config.validsegments) {
        config.validsegments.forEach(element => validSegments.push(element))
        //validSegments.forEach(element => logger.warn(element))
      } else {
        console.log()
        logger.warn('Config: No valid segment(s) found to keep for sitemaps. Exiting \n')
        this.stop()
      }

      // note that preferredsegment is a string and not an array in the playbook
      // if omitted, validSegments are used
      let preferredSegments = validSegments
      if(config.preferredsegment) {
        if (validSegments.includes(config.preferredsegment)) {
          preferredSegments = []
          preferredSegments.push(config.preferredsegment)
        } else {
          console.log()
          logger.warn('Config: preferredsegment, if set, must match one of the validsegments. Exiting \n')
          this.stop()
        }
      }

      // sitemaps processed will be printed to the console
      let printSitemapFound = null
      if(config.printsitemapfound) {
        printSitemapFound = true
      } else {
        printSitemapFound = false
      }

      // changed content of sitemaps processed will be printed to the console
      let printContent = null
      if(config.printcontent) {
        printContent = true
      } else {
        printContent = false
      }

      // check if there is a sitemap file present and load its content
      // return to Antora if no sitemap file is found

      var content = null
      const main_sitemap_file = outputDir + '/' + smf
      try {
        content = await get_file_from_local(main_sitemap_file)
      } catch (e) {
        console.log('\n')
        logger.warn('There is an error accessing the ' + smf + ' file. Continuing with Antora')
        if (e.code === 'ENOENT') {
          logger.warn(smf + ' not found at:')
          logger.warn(main_sitemap_file)
        } else {
          logger.warn(e)
        }
        console.log('\n')
        return
      }

      // based on the content of the main sitemap file, check which ones to parse
      // return to Antora if no parsable tags are found: (</url> | </sitemap>

      var parsable_sitemaps = []
      if (content.includes('</url>')) {
        // the sitemap file itself uses url tags which only occurs when no sub-sitemaps are used 
        parsable_sitemaps.push(outputDir + '/' + smf)
      } else if (content.includes('</sitemap>')) {
        // check for sub-sitemaps
        parsable_sitemaps = get_parsable_sitemap_files (content, siteUrl + '/', outputDir + '/')
        if (!parsable_sitemaps.length) {
          console.log('\n')
          logger.warn('No parseable sub-sitemaps found in '+ smf + ' Continuing with Antora')
          console.log('\n')
        return
        }
      } else {
        // nothing found at all, something must have went wrong with the sitemap created by Antora
        console.log('\n')
        logger.warn('No parseable content found in '+ smf + ' Continuing with Antora')
        console.log('\n')
        return
      }
      
      // parse each sitemap, replace content on matches and save the result:
      // remove any entries that are NOT defined via config variables

      console.log()
      for (const element of parsable_sitemaps) {
        await parse_sitemap_file(parsable_sitemaps.length, outputDir, content,
                siteUrl, validSegments, preferredSegments, printSitemapFound, printContent, logger, element)
      }
    })
}

/**
 * parse the sitemap file that is handed over and save any changes back
 * 
 * @param  {integer} total_sitemaps       the number of sitemap files found
 * @param  {string}  content              the content of sitemap.xml
 * @param  {string}  site_url             the siteURL to build for
 * @param  {string}  output_dir           the directory where the sitemap files are located
 * @param  {bool}    print_sitemap_found  print the sitemap file component name
 * @param  {bool}    print_content        print the changed sitemap file content
 * @param  {array}   valid_segments       array of segments that are technically valid
 * @param  {array}   preferred_segments   array of segments that will be  more than one valid_segments
 * @param  {object}  logger               the logger object
 * @param  {string}  file                 the sitemap file to process
 * @return                                no data returnd
 */
async function parse_sitemap_file (total_sitemaps, output_dir, content, site_url, valid_segments,
  preferred_segments, print_sitemap_found, print_content, logger, file) {

    // get the name of the component from the filename or the contents of the file
    // the component name is important to properly strip off all data from the left that is not required 
    // for multi version components, this will always be a component name
    // for single version components: either empty || a component name
    var component = ''
    if (total_sitemaps > 1) {
      // because there are more sitemap files, the component name can be derived from the filename
      component = file.replace(output_dir + '/', '').replace(sitemap_keyword, '').replace('.xml', '')
    } else {
      // because there is only one sitemap file, the component name must be gathered from the contents
      const first_match = content.match(/<loc>([^<]*)<\/loc>/)
      const temp_string = first_match[0].replace('<loc>','').replace('</loc>','').replace(site_url + '/','')
      const index = temp_string.indexOf('/')
      component = temp_string.substring(0, index)
    }

    // if the compoentn name is empty, there is nothing to do, because it is a versionless ROOT component
    if (component.length === 0) return

    // get the contents of the sitemap file
    try {
      var sitemap_content = await get_file_from_local(file)
    } catch (e) {
      console.log('\n')
      logger.warn('Cant access file. Continuing with next sitemap file.')
      if (e.code === 'ENOENT') {
        logger.warn(file + ' not found')
      } else {
        logger.warn(e)
      }
      console.log('\n')
      return
    }

    // print the component name of the sitemap file found
    if (print_sitemap_found) {
     logger.warn('Processing component: ' + component)
    }

    // get all multiline blocks with <url> ... </url> 
    const all_url_matches = sitemap_content.match(/(?:<url>)[\s\S]*?(?:<\/url>)/gm)

    // if there is no <url> ... </url> structure, return, nothing needs to be done for this file
    if (all_url_matches.length === 0) {
      if (print_sitemap_found) {
        logger.warn('No processable data found, continuing')
      }
      return
    }
    

    var i = null
    var hit = null
    var version = null
    var has_changed = false

    for (i=0; i < all_url_matches.length; i++) {
      hit = true
      // extract the version from the url. here, a location always has a version. no version case is sorted out above
      // <loc>http://localhost:8080/component/version/file.html</loc>
      version = all_url_matches[i].match(/<loc>([^<]*)<\/loc>/gm).toString()
      version = version.replace('<loc>','').replace('</loc>', '').replace(site_url + '/', '').replace(component + '/', '')
      version = version.substring(0, version.indexOf("/"))

      // check if there is a miss. version found does not match the version allowed
      if (valid_segments.includes(version)) {
        if (preferred_segments.includes(version)) {
          hit = false
          has_changed = true
        }
      }

      // the block identified needs to be removed
      if (hit) {
        sitemap_content = sitemap_content.replace(all_url_matches[i], '')
      }
    }

    // if nothing has changed, return
    if (!has_changed) {
      if (print_sitemap_found) {
        logger.warn('The content of the sitemap was not changed')
      }
      return
    }

    // remove all blank lines caused by the removal process
    sitemap_content = removeEmptyLinesRegex(sitemap_content)

    // print the content of the sitemap file
    if (print_content) {
      logger.warn('New content:')
      console.log(sitemap_content)
    }

    // write the changed content back to file 
    // on error, we cant predict most common ones, so we print the complete message 
    try {
      fs.writeFileSync(file, sitemap_content, {encoding: 'utf8', mode: 0o664})
    } catch (e) {
      console.log(e)
    }

    if (print_sitemap_found) {
      logger.warn('New sitemap data successfully written back')
    }

    return
}

/**
 * return the string content with removed blank lines
 * 
 * @param  {string} content         string that contains possibly blank lines
 * @return {array}  result          string that has t 
 * 
 */
function removeEmptyLinesRegex(content) {
  // Regex explanation:
  // ^: Matches the beginning of a line
  // \s*: Matches zero or more whitespace characters (space, tab, newline, etc.)
  // $: Matches the end of a line
  // /gm: Global (g) and multiline (m) flags
  //    'g' ensures all matches are replaced, not just the first.
  //    'm' ensures '^' and '$' match the start/end of each line, not just the entire string.
  return content.replace(/^\s*[\r\n]/gm, '').replace(/(\r\n|\r|\n){2,}/g, '$1');
}

/**
 * return an array with parsable sitemap files
 * 
 * @param  {string} content         the content of sitemap.xml
 * @param  {string} site_url        the siteURL to build for
 * @param  {string} output_dir      the directory where the sitemap files are located
 * @return {array}  result          a list of full-path sitmap files to parse
 */
function get_parsable_sitemap_files (content, site_url, output_dir) {
// https://www.linkedin.com/pulse/parsing-xml-javascript-python-sergiu-panaite-1
    const all_matches = content.match(/<loc>([^<]*)<\/loc>/g)
    // all_matches.forEach(element => console.log(element))

    // exit if no sub-sitemaps can be found, then the array is not initialized
    if (!Array.isArray(all_matches)) { return [] }

    // strip off the xml tag and the site_url
    var i = null
    var temp_res = []
    for (i=0; i < all_matches.length; i++) {
      temp_res[i] = all_matches[i].replace('<loc>','').replace('</loc>','').replace(site_url,'')
    }
    //temp_res.forEach(element => console.log(element))

    // add the path
    const result = temp_res.map(element => `${output_dir}${element}`)
    // result.forEach(element => console.log(element))

    return result
}

/**
 * read the contents of a given file
 * 
 * @param  {string} file        the file to read
 * @return {string} data        the data from the file read
 * @return {object} error       the error if thrown, needs try/catch from the caller
 */
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
