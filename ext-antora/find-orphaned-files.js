'use strict'

/**
 * Find Orphaned Files Extension.
 * Version 1.0.1
 * 
 * @param {Object} config   configuration object      - Configuration provided by site.yml
 * @param {Bool}            config.printavailable     - Print available components/versions first
 * @param {String}          config.stopafterfind      - Stop build process after extension has run
 * @param {String}          config.falsepositives     - Ignore files collected in a file, 'modules/...' 
 * @param {Array<string>}   [config.excludeextension] - Extensions to exclude from detection ['.png', ...]
 * @param {Array<string>}   [config.pathfilter]       - Strings to exclude from detection ['modules/ROOT', ...]
 * @param {Array<string>}   [config.excludecomponents]- Components to exclude from detection ['my_comp', ...]
 */

const fs    = require('fs')

module.exports.register = function ({config}) {
    const logger = this.getLogger('find-orphaned-objects')

    this.on('contentClassified', ({ contentCatalog }) => {

      // if config.printavailable is provided, first print which components and versions are available
      const printAvailable = (config.printavailable) ? true : false
      // console.log(printAvailable)

      // if config.stopafterfind is provided, stop when the build process has completed
      const stopAfterFind = (config.stopafterfind) ? true : false
      // console.log(printAvailable)

      // if config.extensionToIgnore is provided, ignore these extensions
      const extensionToIgnore = []
      if(config.excludeextension) {
          config.excludeextension.forEach(element => extensionToIgnore.push(element))
          // extensionToIgnore.forEach(element => console.log(element))
      }

      // if config.pathfilter is provided, ignore paths containing the strings 
      const pathsToIgnore = []
      if(config.pathfilter) {
          config.pathfilter.forEach(element => pathsToIgnore.push(element))
          // pathsToIgnore.forEach(element => console.log(element))
      }

      // if config.excludecomponents is provided, ignore components containing the strings 
      const excludeComponents = []
      if(config.excludecomponents) {
          config.excludecomponents.forEach(element => excludeComponents.push(element))
          // excludeComponents.forEach(element => console.log(element))
      }

      const falsepositives = get_falsepositives(config, logger)
      // falsepositives.forEach(element => console.log(element))

      // regex to identify if there are keys in pages that contain includable objects
      // note that audio and video family directories are currenly not implemented antora
      // note only use macros that have a family directory
      // g1 ... any character before g2, allowed: whitespaces, start of string and .macro at the line start
      // g2 ... any of the named macros, note that the : is a mandatory part
      // g3 ... optional for an additional : (like image can have : and ::)
      // g4 ... the relevant path, only use if it not empty
      const rg = /([\s*]|^[\.]|\A)(image:|include:|xref:)(:{1}|^\r)?([^\s|^\[]*)/g

      // array to define which macro stores/refernces its files in which default family root folder
      // note that include and xref can reference, if not otherwise defined, also to the
      // attachments and examples folder
      // key = part of the path like partials$, value = default family directory if not otherwise defined
      const fam_dir_arr = {attachment: 'attachments',
                           example: 'examples',
                           include: 'pages',
                           partial: 'partials',
                           image: 'images',
                           xref: 'pages'
                           //audio: 'images',      // family currently not implemented in Antora
                           //video: 'images'       // family currently not implemented in Antora
                          }

      logger.warn('Start finding orphaned files')

      // first print available component, version which would be processed
      if (printAvailable) {
        console.log('\nThe following will be parsed if not excluded. This may cause false positives!')
        console.log('This happens when you define additional components to satisfy build references.\n')
        contentCatalog.getComponents().forEach(({ versions }) => {
          versions.forEach(({ name: component, version }) => {
            console.log(component, version)
          })
        })
      }

      contentCatalog.getComponents().forEach(({ versions }) => {
        versions.forEach(({ name: component, version }) => {

          if (excludeComponents.indexOf(component) > -1) {    // skip component if excluded
            return
          }

          console.log('\n')
          console.log('# ' + component, version, '\n')

          // get ALL files from the content catalog, which is a list of files that Antora
          // identifies on the filesystem to be considered for the docs build process
          // remove those files we do not want to be part of
          const allFiles = get_all_files (contentCatalog, extensionToIgnore, pathsToIgnore)
          // allFiles.forEach(element => console.log(element))

          const dir_sep = get_dir_seperator(allFiles)

          const pages = contentCatalog.findBy({ component, version, family: 'page' })
          const pageReferences = get_path_objects (pages, rg, fam_dir_arr, dir_sep, this)
          // pageReferences.forEach(element => console.log(element))

          const partials = contentCatalog.findBy({ component, version, family: 'partial' })
          const partialReferences = get_path_objects (partials, rg, fam_dir_arr, dir_sep, this)
          // partialReferences.forEach(element => console.log(element))

          const nav = contentCatalog.findBy({ component, version, family: 'nav' })
          const navReferences = get_path_objects (nav, rg, fam_dir_arr, dir_sep, this)
          // navReferences.forEach(element => console.log(element))

          const navFiles = get_all_nav_files (nav)
          // navFiles.forEach(element => console.log(element))

          // this are all unique files that get referenced by authors inside docs
          // collect all references into an array to sort before adding to the set
          const coll = []
          pageReferences.forEach((element)    => coll.push(element))
          partialReferences.forEach((element) => coll.push(element))
          navReferences.forEach((element)     => coll.push(element))
          // coll.sort().forEach(element => console.log(element))

          const allUniqueReferences = new Set(coll.sort())
          // allUniqueReferences.forEach(element => console.log(element))

          // remove found navigation files from allFiles list
          const allFilesNoNav = setDifference(allFiles, navFiles)
          // allFilesNoNav.forEach(element => console.log(element))

          // remove false positives from allFilesNoNav list
          const allFilesNoNavNoFalsePositives = setDifference(allFilesNoNav, falsepositives)
          // allFilesNoNavNoFalsePositives.forEach(element => console.log(element))

          // remove found unique references from allFilesNoNavNoFalsePositives list
          // the list of (a) allFilesNoNavNoFalsePositives is the base we substract (b) allUniqueReferences from
          // ideally, this lists are equal and no remaining elements are found
          const orphandArray = setDifference(allFilesNoNavNoFalsePositives, allUniqueReferences)
          // orphandArray.forEach(element => console.log(element))

          orphandArray.forEach(element => console.log(element))

        })
      })

      console.log('\n')
      logger.warn('End finding orphaned files')

      if (stopAfterFind) {
        logger.warn('Stopping build process by config')
        console.log('\n')
        this.stop()
      } else {
        console.log('\n')
      }

    })
}

/**
 * return the differernce between two sets (a_set\b_set)
 * we could make it shorter, but the we cant debug it
 * 
 * @param  {set} a_set       the first set
 * @param  {set} b_set       the second set
 * @return {set} d_set       the difference between a and b (a_minus_b)
 */
function setDifference(a_set, b_set) {
    const d_set = new Set(Array.from(a_set).filter(x => {
      const not_found = !b_set.has(x)                          // needs to be a set because of has
      // console.log(not_found, x)
      return not_found
    }))
    return d_set
}

/**
 * if config.falsepositives is provided, create set to later ignore these files
 * 
 * @param  {object} config       the config object
 * @param  {object} logger       the logger object
 * @return {set} falsepositives  an array that contains all files
 */
function get_falsepositives(config, logger) {
    var falsepositives = new Set

    if (config.falsepositives) {
      try {
        const text = fs.readFileSync(config.falsepositives, 'utf-8')
          text.split(/\r?\n/).forEach(line =>  {
            const lt = line.trim()
            if (lt.length == 0) {          // no empty lines
              return
            }
            if (lt.startsWith('#')) {      // no commented lines
              return
            }
            falsepositives.add(lt)
        })
      // loading or processing the file caused an error
      } catch (error) {
        logger.warn(error.message)
      }
    }
    return falsepositives
}

/**
 * get a list of all files from the contentCatalog
 * exclude files that match an extension from an config array list
 * exclude files that contain a string from an config array list
 * 
 * @param  {object} contentCatalog      the navigation catalog object
 * @param  {array}  extensionToIgnore   a list of extension to exclude
 * @param  {array}  pathsToIgnore       an array of strings to exclude
 * @return {array}  files_set           a set that contains all files
 */
function get_all_files (contentCatalog, extensionToIgnore, pathsToIgnore) {
    const files = []
    const ex_files = []

    if (extensionToIgnore.length === 0) {        // get all files
      contentCatalog.getFiles()
        .forEach(file => {
           const item = '' + file.src.path
           files.push(item)
      })
    } else {                                     // only files that dont match an extension pattern
      contentCatalog.getFiles()
        .forEach(file => {
           const item = '' + file.src.path       // can cause string 'undefined'
           let found = extensionToIgnore.some(ext => {
             return item.endsWith(ext)           // return and exit some if true
           })
           if (!found && item != 'undefined') {  // only if found and not the string 'undefined'
             files.push(item)
           }
         })
    }

    files.forEach(item => {
      let found
      found = pathsToIgnore.some(str => {
        return item.includes(str)                // return and exit some if true
      })
      if (!found && item != 'undefined') {       // only if found and not the string 'undefined'
        ex_files.push(item.trim())
      }
    })

    // ex_files.sort().forEach(element => console.log(element))

    const files_set = new Set(ex_files.sort().filter(Boolean))  // sort, remove true undefined
    return  files_set                            // return set
}

/**
 * get a list of all navigation files
 * 
 * @param {object} navigationCatalog    the navigation catalog object
 * @return {set} files                  a set that contains all navigation files
 */
function get_all_nav_files (navigationCatalog) {
    // get a list of all navigation files

    const files = new Set
    for (const item of navigationCatalog) {
      files.add(item.src.path)
    }
    // console.log(files)
    return files
}

/**
 * identify and return the directory separator used by the OS
 * this is needed when assembling the path in <get_path_objects> function
 * 
 * @return {string} dir_sep   the directory separator used
 */
function get_dir_seperator(allFiles) {
    let dir_sep = '/' // defaults to linux based directory separator if array is empty to avoid errors

    if (allFiles.length) {                             // overwrite the default
      dir_sep = allFiles[0].includes('/') ? '/' : '\\' // either linux '/' or windows '\\'
    }
    return dir_sep
}

/**
 * get all paths that are defined in macros in via a regex
 * x is the 'this' object and only needed for development like when using x.stop()
 * 
 * the final path assembled looks like the following, which matches the scheme of get_all_files()
 * 'modules/<module>/<family>/path/file.ext' like 'modules/ROOT/pages/abc/file.adoc'
 * 
 * @param  {object} pages
 * @param  {string} rg  
 * @param  {array}  fam_dir_arr
 * @param  {string} dir_sep
 * @param  {object} x                      this from the caller
 * @return {set}    uniqueObjectRefernces  contains all unique paths
 */
function get_path_objects (pages, rg, fam_dir_arr, dir_sep, x) {
    const s1 = []
    const objectReferences = []
    const uniqueObjectRefernces = new Set()

    // regex over all pages, only group 2 and 4 are relevant
    for (const page of pages) {
      const iterator  = [...page._contents.toString().matchAll(rg)]
      const g2 = iterator.map(m => m[2]) // macro
      const g4 = iterator.map(m => m[4]) // path

      if (g2.length > 0) {                        // only if at least one match was found in a page
        for (let i=0; i < g2.length; i++) {       // for all matches found do

          if (g2[i] && g4[i]) {                   // only if there is content in groups 2 and 4
            const macro = g2[i].replace(/:$/, '') // remove any colon if exists, needed to get array value

            let [family, path] = g4[i].split('$') // check if we have a family coordinate like partials$
            if (path === undefined || path.length == 0) {  // path is empty when no $ is found
              [family, path] = [path, family]     // if path is empty = no family coordinate, swap the vars
              family = macro                      // populate the default familiy coordinate from the array
            }

            if (path.includes('{')) {             // if path contains a '{' == attribute usage 
              continue                            // refuse, we cant resolve attributes to get the final path
            }

            if (path.includes('@')) {             // if path contains a '@' == xref version reference 
              continue                            // refuse, we do not check version references
            }                                     // version@component, remaining: module = ok

            const htp = path.toLowerCase()        // note that a module can be named http...
            const isHttp = (htp.startsWith('http://') || htp.startsWith('https://'))
            if (isHttp) {                         // macros like include and xref can contain an URL
              continue                            // refuse, we do not check external resources
            }

            const a = path.split(dir_sep).pop()   // get the last path component - if it is a path
            const isFile = a.search(/([?.+].+)/g) // if there is a . it is a file, else it is a xref refernce
            if (isFile < 0) {                     // skip xref section references
              continue                            // refuse, section references are no files
            }

            if (path.includes('#')) {             // if path contains a '#' == xref anchor ref usage 
              path = path.substring(0, path.indexOf('#')) // remove the section usage
            }

            if (path.startsWith('./') || path.startsWith('.\\')) { // reconstruct the full path component if relative
              const basename = page.src.basename  // the pure file name
              const relative = page.src.relative  // the relative directory of the page
              const re_wo_bas = relative.substring(0,relative.lastIndexOf(basename)-1)
              path = re_wo_bas + path.substring(1) // assemble a correct FULL relative path
            }

            path = path.replaceAll('//', '/')     // linux only: replace any path occurrences of '//' with '/'
                                                  // windows   : does not allow double path separators '\\' = np

            if (path.startsWith('/') || path.startsWith('\\')) {   // if path start with '/' or '\'
              path = path.substring(1)            // remove first path separator if extists
            }

            // family can contain a : like manual_1:page
            // this references to another module like: manual_1:pages/xyz/page.adoc
            // path can also contain a : like manual_1:pages
            // otherwise, when there is no coordinate given, assemble it manually
            // xyz/file.adoc --> <module>/<family-path>/xyz/file.adoc

            if (family.includes(':')) {                    // manual_1:page --> manual_1/pages
              const fam = family.split(':').pop()          // get the family
              const fams = dir_sep + fam_dir_arr[fam]      // create a replacement string
              family = family.replace(':' + fam, fams)     // make it a path like manual_1/pages
              path = family + dir_sep + path               // assemble the path like manual_1/pages/xyz/file.adoc
            } else if (path.includes(':')) {               // make it a path like manual_1/pages
              path = path.replace(':', dir_sep + fam_dir_arr[family] + dir_sep)
            } else {                                       // manually assemble the path using the fam_dir_array
              path = page.src.module + dir_sep + fam_dir_arr[family] + dir_sep + path
            }                                     // now we have a guaranteed complete path

            path = 'modules' + dir_sep + path     // ROOT/pages/xyz/file.adoc --> modules/ROOT/pages/xyz/file.adoc
            s1.push(macro, family, path)          // technically only path is necessary
          }                                       // we use all three for debuggiung purposes
        }
      }
    }

    // note there must be the same number of splice elements as defined in s1.push above
    // splice makes the path accessible always on the same index 
    while(s1.length) objectReferences.push(s1.splice(0,3))

    // now we have the correct raw data
    // create the final set of objects = uniqe entries

    // the path is on the last location, see splice
    for (let i=0; i < objectReferences.length; i++) {
      uniqueObjectRefernces.add(objectReferences[i][2].trim())
    }

    return uniqueObjectRefernces
}
