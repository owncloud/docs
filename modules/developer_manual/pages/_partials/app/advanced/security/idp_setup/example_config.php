<?php

$CONFIG = array (
    // ...remaining configuration
    'openid-connect' => [
        'client-id' => 'ownCloud',
        'client-secret' => 'ownCloud',
        'loginButtonName' => 'login',
        'mode' => 'userid',
        'provider-url' => 'http://idp.example.com:3000',
        'search-attribute' => 'sub',
        'use-token-introspection-endpoint' => true
    ],
);
