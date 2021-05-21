@api @federation-app-required @files_sharing-app-required @notToImplementOnOCIS
Feature: federated share of public link share

  Background:
    Given using server "REMOTE"
    And user "Alice" has been created with default attributes and without skeleton files
    And using server "LOCAL"
    And user "Alice" has been created with default attributes and without skeleton files
    And user "Brian" has been created with default attributes and without skeleton files

  Scenario: Mount public share (internal server)
    Given user "Alice" has created folder "/PARENT"
    And user "Alice" has uploaded file "filesForUpload/textfile.txt" to "PARENT/textfile0.txt"
    And user "Alice" has created a public link share with settings
      | path        | /PARENT                   |
      | permissions | read,update,create,delete |
    When user "Brian" from server "LOCAL" adds public share created by user "Alice" from local server
    Then the HTTP status code should be "200"