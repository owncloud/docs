# Updating the Search Index

The search index is maintained using the Algolia docsearch-scraper Docker image.
The script below provides an example of how to use it to scrape the documentation, and to update the existing search index, based on any changes that it finds.
The documentation URL, along with the index name and other related settings are specified in docsearch-scraper/owncloud.json.

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

**Note:** Values for the environment variables which don’t already have values specified are available at: https://www.algolia.com/apps/RQPV9Q61S4/api-keys/all.
If you need account access, please contact tboerger@owncloud.com.
