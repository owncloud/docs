<?php

use GuzzleHttp\Client;

require_once ('vendor/autoload.php');

// Configure the basic client
$basePath = '{oc-examples-server-url}';
$requestPath = 'ocs/v2.php/cloud/user-sync/admin';
$username = '{oc-examples-username}';
$password = '{oc-examples-password}';

$client = new Client([
    'base_uri' => $basePath,
]);

try {
    $response = $client->post($requestPath, [
        'auth' => [$username, $password],
        'debug' => true,
    ]);
    print $response->getBody()->getContents();
} catch (\GuzzleHttp\Exception\ClientException $e) {
    print $e->getMessage();
}

