/**
 * @When the administrator changes the password of user :user to :password using the provisioning API
 *
 * @param string $user
 * @param string $password
 *
 * @return void
 * @throws \Exception
 */
public function adminChangesPasswordOfUserToUsingTheProvisioningApi(
    $user, $password
) {
    $this->response = UserHelper::editUser(
        $this->getBaseUrl(),
        $user,
        'password',
        $password,
        $this->getAdminUsername(),
        $this->getAdminPassword()
    );
}

