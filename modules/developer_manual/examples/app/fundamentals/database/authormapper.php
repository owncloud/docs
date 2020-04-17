<?php
// db/authormapper.php

namespace OCA\MyApp\Db;

use OCP\IDBConnection;
use OCP\AppFramework\Db\Mapper;

class AuthorMapper extends Mapper {

    public function __construct(IDBConnection $db) {
        parent::__construct($db, 'myapp_authors');
    }

    /**
     * @throws \OCP\AppFramework\Db\DoesNotExistException if not found
     * @throws \OCP\AppFramework\Db\MultipleObjectsReturnedException if more than one result
     */
    public function find($id) {
        $sql = 'SELECT * FROM `*PREFIX*myapp_authors` ' .
            'WHERE `id` = ?';
        return $this->findEntity($sql, [$id]);
    }


    public function findAll($limit=null, $offset=null) {
        $sql = 'SELECT * FROM `*PREFIX*myapp_authors`';
        return $this->findEntities($sql, $limit, $offset);
    }


    public function authorNameCount($name) {
        $sql = 'SELECT COUNT(*) AS `count` FROM `*PREFIX*myapp_authors` ' .
            'WHERE `name` = ?';
        $stmt = $this->execute($sql, [$name]);

        $row = $stmt->fetch();
        $stmt->closeCursor();
        return $row['count'];
    }
}
