<?php
// db/authordao.php

namespace OCA\MyApp\Db;

use OCP\IDBConnection;

class AuthorDAO {

    private $db;

    public function __construct(IDBConnection $db) {
        $this->db = $db;
    }

    public function find($id) {
        $sql = 'SELECT * FROM `*PREFIX*myapp_authors` WHERE `id` = ?';
        $stmt = $this->db->prepare($sql);
        $stmt->bindParam(1, $id, \PDO::PARAM_INT);
        $stmt->execute();
        $row = $stmt->fetch();
        $stmt->closeCursor();

        return $row;
    }
}
