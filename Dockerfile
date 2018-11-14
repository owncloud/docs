FROM antora/antora

LABEL maintainer="matthew@matthewsetter.com"

# Enable Lunr site search integration and generation of a Lunr search index by default 
ENV DOCSEARCH_ENABLED true
ENV DOCSEARCH_ENGINE lunr

WORKDIR /antora

COPY package* /antora/

RUN apk add --no-cache build-base libressl-dev libcurl libgit2-dev python && \
    ln -s /usr/lib/libcurl.so.4 /usr/lib/libcurl-gnutls.so.4 && \
    BUILD_ONLY=true npm install nodegit

# Install the required (custom) NPM packages. 
# This is required as the ownCloud build requires extra packages so that Lunr
# search can be integrated.
RUN npm i
