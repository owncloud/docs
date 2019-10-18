<?php

use GuzzleHttp\Client;

require_once('vendor/autoload.php');

// Configure the basic client
$client = new Client([
    'base_uri' => '{oc-examples-server-url}/remote.php/dav/',
]);

$share_token = '<share_token>';

try {
    $response = $client->request('PROPFIND', "public-files/$\{share_token\}", [
        'headers' => [
            'Content-Type'=> 'text/xml',
        ],
    ]);
    print $response->getBody()->getContents();
} catch (\GuzzleHttp\Exception\ClientException $e) {
    print $e->getMessage();
}
