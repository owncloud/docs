'use strict'

// Antora extension to create a new and clean search index based on ElasticSearch

const _ = require('lodash')
const cheerio = require('cheerio')
const Entities = require('html-entities')
const { Client } = require('@elastic/elasticsearch')

module.exports.register = function () {
  // run when the Antora site publishing event has been fired = all done
  // get all the pages created and index the result
  this.on('sitePublished', ({ playbook, contentCatalog }) => {
    const pages = contentCatalog.getPages()
    generateIndex(playbook, pages)
  })
}

async function generateIndex(playbook, pages) {
  // this env is usually not set when building local - skip indexing
  // but when set, we index, also when building local
  // only set in .drone.star in the docs repo when doing a full build
  if (process.env.UPDATE_SEARCH_INDEX !== 'true') {
    console.log('ElasticSearch: index generation skipped')
    return
  } else {
    console.log('ElasticSearch: indexing requested')
  }

  // note that the following envvars are required to build the index
  // see the documentation at docs/README.md and docs-ui/src/partials/header-content.hbs for more information
  if (!process.env.ELASTICSEARCH_NODE) {
    console.log('ElasticSearch: ELASTICSEARCH_NODE envvar is missing, indexing skipped')
    return
  }
  if (!process.env.ELASTICSEARCH_INDEX) {
    console.log('ElasticSearch: ELASTICSEARCH_INDEX envvar is missing, indexing skipped')
    return
  }
  if (!process.env.ELASTICSEARCH_WRITE_AUTH) {
    console.log('ElasticSearch: ELASTICSEARCH_WRITE_AUTH envvar is missing, indexing skipped')
    return
  }

  let siteUrl = playbook.site.url
  if (!siteUrl) {
    siteUrl = ''
  }

  const index_start = Date.now()

  // index the documents available
  const documents = pages.map((page) => {
    // a document like '_email-config.adoc' gets excluded from the catalog
    // because it has a leading '_' which will result in an undefined
    // 'page.pub.url' variable breaking generating the index
    if (page.pub === undefined) {
      return
    }

    const titles = []

    const html = page.contents.toString()
    // for performance reasons, we use parameter xml which then uses the htmlparser2 engine.
    // for more details see:
    // https://cheerio.js.org/docs/api/interfaces/CheerioOptions
    // https://github.com/taoqf/node-html-parser#performance
    const $ = cheerio.load(html, { xml: true })

    const $article = $('article')
    const title = $article.find('h1').text()

    $article.find('h1,h2,h3,h4,h5,h6').each(function () {
      let $title = $(this)
      let id = $title.attr('id')

      titles.push({
        text: $title.text(),
        id: $title.attr('id'),
        url: siteUrl + page.pub.url + '#' + $title.attr('id')
      })

      $title.remove()
    })

    let text = Entities.decode($('article').text())
      .replace(/(<([^>]+)>)/gi, '')
      .replace(/\n/g, ' ')
      .replace(/\r/g, ' ')
      .replace(/\s+/g, ' ')
      .trim()

    // todo, we want to do more fancy stuff with results
    // also see: docs-ui/src/js/vendor/elastic.js
    return {
      component: page.src.component,
      version: page.src.version,
      name: page.src.stem,
      title: title,
      text: text,
      url: siteUrl + page.pub.url,
      titles: titles
    }
  })

  // prepare index for uploading
  let result = []
  documents.forEach((document, index) => {
    result.push({
      index: {
        _index: process.env.ELASTICSEARCH_INDEX,
        _type: 'page',
        _id: index
      }
    })

    result.push(document)
  })

  // create a new client to connect
  const client = new Client({
    node: process.env.ELASTICSEARCH_NODE,
    auth: {
      username: process.env.ELASTICSEARCH_WRITE_AUTH.split(':')[0],
      password: process.env.ELASTICSEARCH_WRITE_AUTH.split(':')[1]
    }
  })

  // remove the old index and create/upload the new one
  try {
    console.log('ElasticSearch: remove old search index')
    await indexDelete(client)
    console.log('ElasticSearch: create empty search index')
    await indexCreate(client)
    console.log('ElasticSearch: upload search index')
    await indexBulk(client, result)
  } catch (err) {
    const errObj = JSON.parse(err)
    console.log('ElasticSearch: ERROR: ' + errObj.status + ' - ' + errObj.error.reason)
    process.exit(1)
  }
  const index_end = Date.now()
  const elapsedTime = (index_end - index_start) / 1000
  console.log(`ElasticSearch: indexing time: ${elapsedTime}s`)
}

function indexDelete(client) {
  return new Promise((resolve, reject) => {
    client.indices
      .delete({
        index: process.env.ELASTICSEARCH_INDEX,
        ignore_unavailable: true
      })
      .then((resp) => {
        resolve(resp)
      })
      .catch((err) => {
        reject(err)
      })
  })
}

function indexCreate(client) {
  return new Promise((resolve, reject) => {
    client.indices
      .create({
        index: process.env.ELASTICSEARCH_INDEX
      })
      .then((resp) => {
        resolve(resp)
      })
      .catch((err) => {
        reject(err)
      })
  })
}

function indexBulk(client, result) {
  return new Promise((resolve, reject) => {
    client
      .bulk({
        body: result
      })
      .then((resp) => {
        resolve(resp)
      })
      .catch((err) => {
        reject(err)
      })
  })
}
