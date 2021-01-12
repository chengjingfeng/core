@api @provisioning_api-app-required @skipOnLDAP
Feature: disable user
  As an admin
  I want to be able to disable a user
  So that I can remove access to files and resources for a user, without actually deleting the files and resources

  Background:
    Given using OCS API version "1"

  @smokeTest
  Scenario: admin disables an user
    Given user "Alice" has been created with default attributes and skeleton files
    When the administrator disables user "Alice" using the provisioning API
    Then the OCS status code should be "100"
    And the HTTP status code should be "200"
    And user "Alice" should be disabled

  @skipOnOcV10.3
  Scenario Outline: admin disables an user with special characters in the username
    Given these users have been created with skeleton files:
      | username   | email   |
      | <username> | <email> |
    When the administrator disables user "<username>" using the provisioning API
    Then the OCS status code should be "100"
    And the HTTP status code should be "200"
    And user "<username>" should be disabled
    Examples:
      | username | email               |
      | a@-+_.b  | a.b@example.com     |
      | a space  | a.space@example.com |

  @smokeTest @notToImplementOnOCIS
  Scenario: Subadmin should be able to disable an user in their group
    Given these users have been created with default attributes and skeleton files:
      | username |
      | Alice    |
      | subadmin |
    And group "brand-new-group" has been created
    And user "subadmin" has been added to group "brand-new-group"
    And user "Alice" has been added to group "brand-new-group"
    And user "subadmin" has been made a subadmin of group "brand-new-group"
    When user "subadmin" disables user "Alice" using the provisioning API
    Then the OCS status code should be "100"
    And the HTTP status code should be "200"
    And user "Alice" should be disabled

  @notToImplementOnOCIS
  Scenario: Subadmin should not be able to disable an user not in their group
    Given these users have been created with default attributes and skeleton files:
      | username |
      | Alice    |
      | subadmin |
    And group "brand-new-group" has been created
    And group "another-group" has been created
    And user "subadmin" has been added to group "brand-new-group"
    And user "Alice" has been added to group "another-group"
    And user "subadmin" has been made a subadmin of group "brand-new-group"
    When user "subadmin" disables user "Alice" using the provisioning API
    Then the OCS status code should be "997"
    And the HTTP status code should be "401"
    And user "Alice" should be enabled

  @notToImplementOnOCIS
  Scenario: Subadmins should not be able to disable users that have admin permissions in their group
    Given these users have been created with default attributes and skeleton files:
      | username      |
      | subadmin      |
      | another-admin |
    And group "brand-new-group" has been created
    And user "another-admin" has been added to group "admin"
    And user "subadmin" has been added to group "brand-new-group"
    And user "another-admin" has been added to group "brand-new-group"
    And user "subadmin" has been made a subadmin of group "brand-new-group"
    When user "subadmin" disables user "another-admin" using the provisioning API
    Then the OCS status code should be "997"
    And the HTTP status code should be "401"
    And user "another-admin" should be enabled

  Scenario: Admin can disable another admin user
    Given user "another-admin" has been created with default attributes and skeleton files
    And user "another-admin" has been added to group "admin"
    When the administrator disables user "another-admin" using the provisioning API
    Then the OCS status code should be "100"
    And the HTTP status code should be "200"
    And user "another-admin" should be disabled

  @notToImplementOnOCIS
  Scenario: Admin can disable subadmins in the same group
    Given user "subadmin" has been created with default attributes and skeleton files
    And group "brand-new-group" has been created
    And user "subadmin" has been added to group "brand-new-group"
    And the administrator has been added to group "brand-new-group"
    And user "subadmin" has been made a subadmin of group "brand-new-group"
    When the administrator disables user "subadmin" using the provisioning API
    Then the OCS status code should be "100"
    And the HTTP status code should be "200"
    And user "subadmin" should be disabled

  Scenario: Admin user cannot disable himself
    Given user "another-admin" has been created with default attributes and skeleton files
    And user "another-admin" has been added to group "admin"
    When user "another-admin" disables user "another-admin" using the provisioning API
    Then the OCS status code should be "101"
    And the HTTP status code should be "200"
    And user "another-admin" should be enabled

  Scenario: disable an user with a regular user
    Given these users have been created with default attributes and skeleton files:
      | username |
      | Alice    |
      | Brian    |
    When user "Alice" disables user "Brian" using the provisioning API
    Then the OCS status code should be "997"
    And the HTTP status code should be "401"
    And user "Brian" should be enabled

  @notToImplementOnOCIS
  Scenario: Subadmin should not be able to disable himself
    Given user "subadmin" has been created with default attributes and skeleton files
    And group "brand-new-group" has been created
    And user "subadmin" has been added to group "brand-new-group"
    And user "subadmin" has been made a subadmin of group "brand-new-group"
    When user "subadmin" disables user "subadmin" using the provisioning API
    Then the OCS status code should be "101"
    And the HTTP status code should be "200"
    And user "subadmin" should be enabled

  @smokeTest
  Scenario: Making a web request with a disabled user
    Given user "Alice" has been created with default attributes and skeleton files
    And user "Alice" has been disabled
    When user "Alice" sends HTTP method "GET" to URL "/index.php/apps/files"
    Then the HTTP status code should be "403"

  Scenario: Disabled user tries to download file
    Given user "Alice" has been created with default attributes and skeleton files
    And user "Alice" has been disabled
    When user "Alice" downloads file "/textfile0.txt" using the WebDAV API
    Then the HTTP status code should be "401"
  
  Scenario: Disabled user tries to upload file
    Given user "Alice" has been created with default attributes and skeleton files
    And user "Alice" has been disabled
    When user "Alice" uploads file with content "uploaded content" to "newTextFile.txt" using the WebDAV API
    Then the HTTP status code should be "401"

  Scenario: Disabled user tries to rename file
    Given user "Alice" has been created with default attributes and skeleton files
    And user "Alice" has been disabled
    When user "Alice" moves file "/textfile0.txt" to "/renamedTextfile0.txt" using the WebDAV API
    Then the HTTP status code should be "401"

  Scenario: Disabled user tries to move file
    Given user "Alice" has been created with default attributes and skeleton files
    And user "Alice" has been disabled
    When user "Alice" moves file "/textfile0.txt" to "/PARENT/textfile0.txt" using the WebDAV API
    Then the HTTP status code should be "401"

  Scenario: Disabled user tries to delete file
    Given user "Alice" has been created with default attributes and skeleton files
    And user "Alice" has been disabled
    When user "Alice" deletes file "/textfile0.txt" using the WebDAV API
    Then the HTTP status code should be "401"

  Scenario: Disabled user tries to share a file
    Given user "Alice" has been created with default attributes and skeleton files
    And user "Brian" has been created with default attributes and without skeleton files
    And user "Alice" has been disabled
    When user "Alice" shares file "textfile0.txt" with user "Brian" using the sharing API
    Then the HTTP status code should be "401"

  Scenario: Disabled user tries to share a folder
    Given user "Alice" has been created with default attributes and skeleton files
    And user "Brian" has been created with default attributes and without skeleton files
    And user "Alice" has been disabled
    When user "Alice" shares folder "/PARENT" with user "Brian" using the sharing API
    Then the HTTP status code should be "401"

  Scenario: getting shares shared by disabled user
    Given user "Alice" has been created with default attributes and skeleton files
    And user "Brian" has been created with default attributes and without skeleton files
    And user "Alice" has shared file "/textfile0.txt" with user "Brian"
    When the administrator disables user "Alice" using the provisioning API
    Then as "Brian" file "/Shares/textfile0.txt" should exist

  Scenario: getting shares shared by disabled user in a group
    Given user "Alice" has been created with default attributes and skeleton files
    And user "Brian" has been created with default attributes and without skeleton files
    And group "group0" has been created
    And user "Brian" has been added to group "group0"
    And user "Alice" has shared folder "/PARENT" with group "group0"
    When the administrator disables user "Alice" using the provisioning API
    Then as "Brian" folder "/Shares/PARENT" should exist

  Scenario: Disabled user tries to create public link share
    Given user "Alice" has been created with default attributes and skeleton files
    And user "Alice" has been disabled
    When user "Alice" creates a public link share using the sharing API with settings
      | path | textfile0.txt |
    Then the HTTP status code should be "401"

  Scenario: getting public link share shared by disabled user using the new public WebDAV API
    Given user "Alice" has been created with default attributes and skeleton files
    And user "Alice" has created a public link share with settings
      | path        | /textfile0.txt |
      | permissions | read           |
    And user "Alice" has been disabled
    When the public downloads the last public shared file using the new public WebDAV API
    Then the HTTP status code should be "404"

  Scenario: getting public link share shared by disabled user using the old public WebDAV API
    Given user "Alice" has been created with default attributes and skeleton files
    And user "Alice" has created a public link share with settings
      | path        | /textfile0.txt |
      | permissions | read           |
    And user "Alice" has been disabled
    When the public downloads the last public shared file using the old public WebDAV API
    Then the HTTP status code should be "200"