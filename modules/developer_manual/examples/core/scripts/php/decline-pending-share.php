<?php

use GuzzleHttp\Client;

require_once ('vendor/autoload.php');

// Configure the basic client
$client = new Client([
    'base_uri' => '{oc-examples-server-url}/ocs/v1.php/apps/files_sharing/api/v1/',
]);

try {
    $response = $client->request(
        'DELETE',
        'shares/pending/<share_id>',
        [
            'auth' => ['{oc-examples-username}', '{oc-examples-password}'],
            'debug' => true,
        ]
    );
    print $response->getBody()->getContents();
} catch (\GuzzleHttp\Exception\ClientException $e) {
    print $e->getMessage();
}
