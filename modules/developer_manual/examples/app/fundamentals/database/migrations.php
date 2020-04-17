<?php

namespace OCA\MyApp\Migrations;

use OCP\Migration\ISchemaMigration;
use Doctrine\DBAL\Schema\Schema;

/**
 * Create initial tables for the app
 */
class Version20171106150538 implements ISchemaMigration {

    /** @var  string */
    private $prefix;

    /**
     - @param Schema $schema
     - @param [] $options
     */
    public function changeSchema(Schema $schema, array $options) {
        $this->prefix = $options['tablePrefix'];

        if (!$schema->hasTable("{$this->prefix}mytable")) {
            $table = $schema->createTable("{$this->prefix}mytable");
            $table->addColumn('id', 'integer', [
                'autoincrement' => true,
                'unsigned' => true,
                'notnull' => true,
                'length' => 11,
            ]);
            $table->addColumn('stringfield', 'string', [
                'length' => 255,
                'notnull' => false,
            ]);
            $table->addColumn('intfield', 'integer', [
                'unsigned' => true,
                'notnull' => true,
                'default' => 1,
            ]);
            $table->setPrimaryKey(['id']);
            $table->addUniqueIndex(['stringfield'], 'mytable_index');
        }
    }
}

