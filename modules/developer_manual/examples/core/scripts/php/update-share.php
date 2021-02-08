<?php

use GuzzleHttp\Client;

require_once ('vendor/autoload.php');

// Configure the basic client
$client = new Client([
    'base_uri' => '{oc-examples-server-url}/ocs/v1.php/apps/files_sharing/api/v1/',
]);

try {
    $response = $client->put('shares/115470', [
        'auth' => ['your.username', 'your.password'],
        'debug' => true,
        'form_params' => [
            'expireDate' => '2017-01-01'
        ]
    ]);
    print $response->getBody()->getContents();
} catch (\GuzzleHttp\Exception\ClientException $e) {
    print $e->getMessage();
}
