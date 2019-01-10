# Update the Search Index

To update the search index you need to use [Algolia's docsearch-scraper](https://github.com/algolia/docsearch-scraper).
If it is not already installed, here is how to do so:

1. Clone [the docsearch-scraper repository](https://github.com/algolia/docsearch-scraper).
2. Install [pipenv](https://pipenv.readthedocs.io/en/latest/install/#installing-pipenv).
3. Initialize and start pipenv by running `pipenv install` and `pipenv shell`.

Once these steps are complete, run the following command, adding the relevant values from [ownCloud's Algolia account](https://www.algolia.com/apps/RQPV9Q61S4/api-keys/all), to update the search index.

**Note:** if you do not have access to ownCloud’s Algolia account, please contact tboerger@owncloud.com.

```
cd docsearch-scraper
APPLICATION_ID=<YOUR_APP_ID> \
API_KEY=<YOUR_API_KEY> \
./docsearch docker:run <path_to_config>
```

This command runs Algolia’s scrapes the documentation and builds a new search index based on the information found; a search index designed and optimized *specifically* for documentation sites.

**Note:** To run this command, you will need [Docker](https://docs.docker.com/) installed.

The configuration file for the script is stored in `algolia-config.json`, located in the root directory of ownCloud's docs repository.
The configuration stores the documentation base URL, along with CSS selectors to help the scraper work with the site’s content structure.

**Note:** Normally, manually updating is not required, as the CI pipeline manages this process, automatically.
However, just in case it is required, this is how to do it.
