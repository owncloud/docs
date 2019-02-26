/**
 * @Given the administrator has changed the password of user :user to :password
 *
 * @param string $user
 * @param string $password
 *
 * @return void
 * @throws \Exception
 */
public function adminHasChangedPasswordOfUserTo(
    $user, $password
) {
    $this->adminChangesPasswordOfUserToUsingTheProvisioningApi(
        $user, $password
    );
    $this->theHTTPStatusCodeShouldBe(
        200,
        "could not change password of user $user"
    );
}

