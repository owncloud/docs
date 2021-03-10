/**
 * @Then /^as "([^"]*)" (file|folder|entry) "([^"]*)" should exist$/
 *
 * @param string $user
 * @param string $entry
 * @param string $path
 *
 * @return void
 * @throws \Exception
 */
public function asFileOrFolderShouldExist($user, $entry, $path) {
    $path = $this->substituteInLineCodes($path);
    $this->responseXmlObject = $this->listFolder($user, $path, 0);
    PHPUnit\Framework\Assert::assertTrue(
        $this->isEtagValid(),
        "$entry '$path' expected to exist but not found"
    );
}

