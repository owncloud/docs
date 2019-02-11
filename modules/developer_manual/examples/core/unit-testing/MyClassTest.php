<?php
namespace OCA\Myapp\Tests;

class MyClassTest extends \Test\TestCase {
    protected $myClass;

    protected function setUp() {
        parent::setUp();
        $this->myClass = new MyClass();
    }

    public function testAddTwo(){
        $this->assertEquals(5, $this->testMe->addTwo(3));
    }
}
