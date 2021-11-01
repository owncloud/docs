/**
 * This script mimics the capability of Asciidoc:
 * Including content by URI in Antora
 * https://docs.asciidoctor.org/asciidoc/latest/directives/include-uri/#reference-include-content-by-uri
 * eg: include::https://raw.githubusercontent.com/asciidoctor/asciidoctor/master/README.adoc[]
 *
 * Note check if you need a leveloffset like [leveloffset=+1]
 * This may be necessary for the makepdf script to avoid having the included content starting on a separate page.
 *
 * Note that the makepdf script needs to have the 'allow-uri-read="" ' attribute param set in the code.
 *
 * Note that no attributes in the included document can be resolved if they are defined outside of this repo
 *
 * Source:
 * Add support for including content from a URL (i.e., remote include)
 * https://gitlab.com/antora/antora/-/issues/246 
 * https://github.com/feelpp/book.feelpp.org/blob/master/lib/remote-include-processor.js
*/
const CIRCUMFIX_COMMENT_SUFFIX_RX = / (?:\*[/)]|--%?>)$/
const NEWLINE_RX = /\r\n?|\n/
const TAG_DELIMITER_RX = /[,;]/
const TAG_DIRECTIVE_RX = /\b(?:tag|(end))::(\S+)\[\]$/
const LINES_DOTDOT_RX = /\.\./


function getTags (attrs) {
    if ( 'tag' in attrs ) {
        const tag = attrs['tag']
        if (tag && tag !== '!') {
            return tag.charAt() === '!' ? new Map().set(tag.substr(1), false) : new Map().set(tag, true)
        }
    } else if ( 'tags' in attrs ) {
        const tags = attrs['tags']
        if (tags) {
            let result = new Map()
            let any = false
            tags.split(TAG_DELIMITER_RX).forEach((tag) => {
                if (tag && tag !== '!') {
                    any = true
                    tag.charAt() === '!' ? result.set(tag.substr(1), false) : result.set(tag, true)
                }
            })
            if (any) return result
        }
    }
}


function applyTagFiltering (contents, tags) {
  let selecting, selectingDefault, wildcard
  if (tags.has('**')) {
    if (tags.has('*')) {
      selectingDefault = selecting = tags.get('**')
      wildcard = tags.get('*')
      tags.delete('*')
    } else {
      selectingDefault = selecting = wildcard = tags.get('**')
    }
    tags.delete('**')
  } else {
    selectingDefault = selecting = !Array.from(tags.values()).includes(true)
    if (tags.has('*')) {
      wildcard = tags.get('*')
      tags.delete('*')
    }
  }

  const lines = []
  const tagStack = []
  const usedTags = []
  let activeTag
  let lineNum = 0
  let startLineNum
  contents.split(NEWLINE_RX).forEach((line) => {
    lineNum++
    let m
    let l = line
    if (
      (l.endsWith('[]') ||
        (~l.indexOf('[] ') &&
          (m = l.match(CIRCUMFIX_COMMENT_SUFFIX_RX)) &&
          (l = l.substr(0, m.index)).endsWith('[]'))) &&
      (m = l.match(TAG_DIRECTIVE_RX))
    ) {
      const thisTag = m[2]
      if (m[1]) {
        if (thisTag === activeTag) {
          tagStack.shift()
          ;[activeTag, selecting] = tagStack.length ? tagStack[0] : [undefined, selectingDefault]
        } else if (tags.has(thisTag)) {
          const idx = tagStack.findIndex(([name]) => name === thisTag)
          if (~idx) {
            tagStack.splice(idx, 1)
            //console.warn(`line ${lineNum}: mismatched end tag in include: expected ${activeTag}, found ${thisTag}`)
          }
          //} else {
          //  //console.warn(`line ${lineNum}: unexpected end tag in include: ${thisTag}`)
          //}
        }
      } else if (tags.has(thisTag)) {
        usedTags.push(thisTag)
        tagStack.unshift([(activeTag = thisTag), (selecting = tags.get(thisTag))])
      } else if (wildcard !== undefined) {
        selecting = activeTag && !selecting ? false : wildcard
        tagStack.unshift([(activeTag = thisTag), selecting])
      }
    } else if (selecting) {
      if (!startLineNum) startLineNum = lineNum
      lines.push(line)
    }
  })
  // Q: use _.difference(Object.keys(tags), usedTags)?
  //const missingTags = Object.keys(tags).filter((e) => !usedTags.includes(e))
  //if (missingTags.length) {
  //  console.warn(`tag${missingTags.length > 1 ? 's' : ''} '${missingTags.join(',')}' not found in include`)
  //}
  return [lines, startLineNum || 1]
}


function getLines (attrs) {
    if ( 'lines' in attrs ) {
        const lines = attrs['lines']
        if (lines) {
            // console.warn(`have lines` + lines)
            let result = [] // new Map()
            let any = false
            lines.split(TAG_DELIMITER_RX).forEach((line) => {
                if (line && line !== '!') {
                    let tryMultipleLines = line.split(LINES_DOTDOT_RX)
                    if ( tryMultipleLines.length === 1 ) {
                        any = true
                        result.push([tryMultipleLines[0], tryMultipleLines[0]])
                    }
                    else if ( tryMultipleLines.length === 2 ) {
                        any = true
                        result.push([tryMultipleLines[0], tryMultipleLines[1]])
                    }
                }
            })
            if (any) return result
        }
    }
}

function applyLineFiltering (contents, linesToInclude) {
    const lines = []
    let lineNum = 0
    let startLineNum
    let registerCurrentLine = false

    const nLinesPair = linesToInclude.length
    let currentLinePair = 0
    let startLine = linesToInclude[currentLinePair][0]
    let endLine = linesToInclude[currentLinePair][1]
    // console.warn(`applyLineFiltering ` + startLine + ' and ' + endLine )

    contents.split(NEWLINE_RX).forEach((line) => {
        lineNum++

        if ( !registerCurrentLine ) {
            if ( lineNum == startLine )
                registerCurrentLine = true
        }

        if ( registerCurrentLine )
        {
            if (!startLineNum) startLineNum = lineNum
            lines.push(line)

            if ( lineNum == endLine ) {
                registerCurrentLine = false
                currentLinePair++
                if ( currentLinePair >= nLinesPair )
                    return [lines, startLineNum]
                else {
                    startLine = linesToInclude[currentLinePair][0]
                    endLine = linesToInclude[currentLinePair][1]
                }
            }
        }
    })
    return [lines, startLineNum || 1]
}

module.exports = function () {
    this.includeProcessor(function () {
        this.$option('position', '>>')
        this.handles((target) => target.startsWith('https://'))
        this.process((doc, reader, target, attrs) => {
            const contents = require('child_process').execFileSync('curl', ['--silent', '-L', target], { encoding: 'utf8' })
            let includeContents = contents
            let startLineNum = 1
            const tags = getTags(attrs)
            const lines = getLines(attrs)
            if (tags) [includeContents, startLineNum] = applyTagFiltering(includeContents, tags)
            else if (lines) [includeContents, startLineNum] = applyLineFiltering(includeContents, lines)
            reader.pushInclude(includeContents, target, target, startLineNum, attrs)
            // reader.pushInclude(contents, target, target, 1, attrs)
        })
    })
}

