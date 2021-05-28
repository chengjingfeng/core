@api @federation-app-required @files_sharing-app-required @notToImplementOnOCIS
Feature: Save public shares created by oC users

  Background:
    Given using server "LOCAL"
    And user "Alice" has been created with default attributes and without skeleton files


  Scenario: Mount public share (local server)
    Given user "Brian" has been created with default attributes and without skeleton files
    And user "Alice" has created folder "/PARENT"
    And user "Alice" has uploaded file "filesForUpload/textfile.txt" to "PARENT/textfile0.txt"
    And user "Alice" has created a public link share with settings
      | path        | /PARENT                   |
      | permissions | read,update,create,delete |
    When user "Brian" from server "LOCAL" adds the last created public share
    Then as "Brian" folder "/PARENT" should exist
  

  Scenario: Mount public share (remote server)
    Given using server "REMOTE"
    And user "Alice" has been created with default attributes and without skeleton files
    And using server "LOCAL"
    And user "Alice" has created folder "/PARENT"
    And user "Alice" has uploaded file "filesForUpload/textfile.txt" to "PARENT/textfile0.txt"
    And user "Alice" has created a public link share with settings
      | path        | /PARENT                   |
      | permissions | read,update,create,delete |
    When user "Alice" from server "REMOTE" adds the last created public share
    # And using server "REMOTE"
    # And as "Alice" folder "/PARENT" should exist