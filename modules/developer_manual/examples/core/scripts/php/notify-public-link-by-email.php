<?php
declare(strict_types=1);

use GuzzleHttp\Client;

require_once ('vendor/autoload.php');

// Configure the basic client
$basePath = '{oc-examples-server-url}';
$requestPath = 'ocs/v1.php/apps/files_sharing/api/v1/notification/notify-public-link-by-email';
$username = '{oc-examples-username}';
$password = '{oc-examples-password}';

$client = new Client([
    'base_uri' => $basePath,
]);

try {
    $response = $client->post($requestPath, [
        'auth' => [$username, $password],
        'form_params' => [
            'recipients' => [
                'user@example.com',
            ],
            'link' => '{oc-examples-server-url}/index.php/s/sfU97LuwePm5omD',
            'personalNote' => 'A personal note.',
        ]
    ]);
    print $response->getBody()->getContents();
} catch (\GuzzleHttp\Exception\ClientException $e) {
    print $e->getMessage();
}