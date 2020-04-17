<?php
$author = new Author();
$author->setName('Some*thing');
$author->slugify('name');  // Some-thing

