<?php
// db/author.php
namespace OCA\MyApp\Db;

use OCP\AppFramework\Db\Entity;

class Author extends Entity {
    protected $stars;
    protected $name;
    protected $phoneNumber;

    // map attribute phoneNumber to the database column phonenumber
    public function columnToProperty($column) {
        if ($column === 'phonenumber') {
            return 'phoneNumber';
        } else {
            return parent::columnToProperty($column);
        }
    }

    public function propertyToColumn($property) {
        if ($column === 'phoneNumber') {
            return 'phonenumber';
        } else {
            return parent::propertyToColumn($property);
        }
    }
}
