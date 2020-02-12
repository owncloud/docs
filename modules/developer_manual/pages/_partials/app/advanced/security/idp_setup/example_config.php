<?php

$CONFIG = array (
    // ...remaining configuration
    'openid-connect' => [
        'client-id' => 'ownCloud',
        'client-secret' => 'ownCloud',
        'loginButtonName' => 'node-oidc-provider',
        'mode' => 'userid',
        'provider-url' => 'http://localhost:3000',
        'search-attribute' => 'sub',
        'use-token-introspection-endpoint' => true
    ],
);
