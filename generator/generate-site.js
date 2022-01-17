'use strict'

const _ = require('lodash')
const cheerio = require('cheerio')
const Entities = require('html-entities')
const { Client } = require('@elastic/elasticsearch')

const aggregateContent = require('@antora/content-aggregator')
const buildNavigation = require('@antora/navigation-builder')
const buildPlaybook = require('@antora/playbook-builder')
const classifyContent = require('@antora/content-classifier')
const convertDocuments = require('@antora/document-converter')
const createPageComposer = require('@antora/page-composer')
const loadUi = require('@antora/ui-loader')
const mapSite = require('@antora/site-mapper')
const produceRedirects = require('@antora/redirect-producer')
const publishSite = require('@antora/site-publisher')
const { resolveConfig: resolveAsciiDocConfig } = require('@antora/asciidoc-loader')

async function generateSite(args, env) {
  const playbook = buildPlaybook(args, env)
  const [contentCatalog, uiCatalog] = await Promise.all([
    aggregateContent(playbook).then((contentAggregate) =>
      classifyContent(playbook, enforceEditurl(contentAggregate))
    ),
    loadUi(playbook)
  ])
  const asciidocConfig = resolveAsciiDocConfig(playbook)
  const pages = convertDocuments(contentCatalog, asciidocConfig)
  const navigationCatalog = buildNavigation(contentCatalog, asciidocConfig)
  const composePage = createPageComposer(playbook, contentCatalog, uiCatalog, env)
  pages.forEach((page) => composePage(page, contentCatalog, navigationCatalog))
  const siteFiles = mapSite(playbook, pages).concat(produceRedirects(playbook, contentCatalog))
  generateIndex(playbook, pages)
  if (playbook.site.url) siteFiles.push(composePage(create404Page()))
  const siteCatalog = { getFiles: () => siteFiles }
  return publishSite(playbook, [contentCatalog, uiCatalog, siteCatalog])
}

async function generateIndex(playbook, pages) {
  if ((process.env.BUILD_SEARCH_INDEX || 'true') !== 'true') {
    console.log('elastic: search index generation skipped')
    return
  }

  console.log('elastic: generate search index')
  let siteUrl = playbook.site.url

  const documents = pages.map((page) => {
    const titles = []

    const html = page.contents.toString()
    const $ = cheerio.load(html)

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

  if (
    process.env.UPDATE_SEARCH_INDEX == 'true' &&
    process.env.ELASTICSEARCH_NODE &&
    process.env.ELASTICSEARCH_INDEX &&
    process.env.ELASTICSEARCH_WRITE_AUTH
  ) {
    console.log('elastic: rebuild search index')
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

    const client = new Client({
      node: process.env.ELASTICSEARCH_NODE,
      auth: {
        username: process.env.ELASTICSEARCH_WRITE_AUTH.split(':')[0],
        password: process.env.ELASTICSEARCH_WRITE_AUTH.split(':')[1]
      }
    })

    try {
      console.log('elastic: remove old search index')
      await indexDelete(client)
      console.log('elastic: create empty search index')
      await indexCreate(client)
      console.log('elastic: upload search index')
      await indexBulk(client, result)
    } catch (err) {
      const errObj = JSON.parse(err)
      console.log('elastic: ERROR: ' + errObj.status + ' - ' + errObj.error.reason)
      process.exit(1)
    }
  }
}

function enforceEditurl(contentAggregate) {
  _.map(contentAggregate, (source) => {
    _.map(source.files, (file) => {
      if (_.startsWith(file.src.editUrl, 'file://')) {
        if (source.name === 'server') {
          file.src.editUrl =
            'https://github.com/owncloud/docs/edit/' + source.version + '/' + file.src.path
        }
      }

      return file
    })

    return source
  })

  return contentAggregate
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

function create404Page() {
  return {
    title: 'Page Not Found',
    mediaType: 'text/html',
    src: { stem: '404' },
    out: { path: '404.html' },
    pub: { url: '/404.html', rootPath: '' }
  }
}

module.exports = generateSite
