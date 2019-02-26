/**
 * @Then /^the groups returned by the API should include "([^"]*)"$/
 *
 * @param string $group
 *
 * @return void
 */
public function theGroupsReturnedByTheApiShouldInclude($group) {
    $respondedArray = $this->getArrayOfGroupsResponded($this->response);
    PHPUnit_Framework_Assert::assertContains($group, $respondedArray);
}

