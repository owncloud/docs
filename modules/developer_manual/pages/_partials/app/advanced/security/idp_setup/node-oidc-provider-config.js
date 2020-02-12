module.exports.clients = [
  {
    client_id: 'ownCloud',
    client_secret: 'ownCloud',
    grant_types: ['refresh_token', 'authorization_code'],
    redirect_uris: ['http://localhost:8080/index.php/apps/openidconnect/redirect'],
    frontchannel_logout_uri: 'http://localhost:8080/index.php/apps/openidconnect/logout'
  }
];
