<?php
// db/author.php
namespace OCA\MyApp\Db;

use OCP\AppFramework\Db\Entity;

class Author extends Entity {

    protected $stars;
    protected $name;
    protected $phoneNumber;

    public function __construct() {
        // add types in constructor
        $this->addType('stars', 'integer');
    }
}

