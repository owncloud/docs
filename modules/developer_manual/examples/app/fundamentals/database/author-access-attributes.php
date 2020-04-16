<?php
// db/author.php
namespace OCA\MyApp\Db;

use OCP\AppFramework\Db\Entity;

class Author extends Entity {
    protected $stars;
    protected $name;
    protected $phoneNumber;
}

$author = new Author();
$author->setId(3);
$author->getPhoneNumber()  // null
