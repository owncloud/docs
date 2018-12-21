# Update the Search Index

To update the search index (likely after a change to the documentation), you need to run the following command, adding the relevant values from [ownCloud’s Algolia account](https://www.algolia.com/apps/RQPV9Q61S4/api-keys/all).

**Note:** if you do not have access to ownCloud’s Algolia account, please contact tboerger@owncloud.com.
```
docker run \
    -v $(pwd)/docsearch-scraper:/opt/docsearch-scraper:ro \
    -e ALGOLIA_APP_ID=<app_id> \
    -e ALGOLIA_API_KEY=<search api key> \
    -e APPLICATION_ID=<app_id> \
    -e API_KEY=<write api key> \
    -e ALGOLIA_INDEX_NAME=owncloud \
    -e CONFIG=/opt/docsearch-scraper/owncloud.json \
     --entrypoint="" \
    algolia/docsearch-scraper pipenv run python -m src.index
```

This command run Algolia’s [docsearch-scraper Docker image](https://github.com/algolia/docsearch-scraper), which scrapes the documentation and builds a new search index based on the information found; a search index designed and optimized *specifically* for documentation sites.

The configuration for the script is stored in `docsearch-scraper/owncloud.json`.
In particular, the configuration stores the documentation base URL, along with CSS selectors to help the scraper work with the site’s content structure.

**Note:** Normally, manually updating is not required, as the CI pipeline manages this process, automatically.
However, just in case it is required, this is how to do it.
