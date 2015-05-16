@product
Feature: Using Totem
  As a Tails user
  I want to watch local and remote videos in Totem
  And AppArmor should prevent Totem from doing dangerous things
  And all Internet traffic should flow only through Tor

  # We cannot use snapshots of an already booted
  # Tails here, due to bugs with filesystem shares vs. snapshots, as
  # explained in checks.feature.

  Background:
    Given I create sample videos

  Scenario: Watching a MP4 video stored on the non-persistent filesystem
    Given a computer
    And I setup a filesystem share containing sample videos
    And I start Tails from DVD with network unplugged and I login
    And I copy the sample videos to "/home/amnesia" as user "amnesia"
    When I open "/home/amnesia/video.mp4" with Totem
    Then I see "SampleLocalMp4VideoFrame.png" after at most 10 seconds
    Given I close Totem
    And I copy the sample videos to "/home/amnesia/.gnupg" as user "amnesia"
    When I try to open "/home/amnesia/.gnupg/video.mp4" with Totem
    Then I see "TotemUnableToOpen.png" after at most 10 seconds

  @check_tor_leaks
  Scenario: Watching a WebM video over HTTPS, with and without the command-line
    Given a computer
    And I start Tails from DVD and I login
    When I open "https://webm.html5.org/test.webm" with Totem
    Then I see "SampleRemoteWebMVideoFrame.png" after at most 60 seconds
    When I close Totem
    And I start Totem through the GNOME menu
    When I load the "https://webm.html5.org/test.webm" URL in Totem
    Then I see "SampleRemoteWebMVideoFrame.png" after at most 60 seconds

  Scenario: Copying video files to a persistence and making sure that they persist
    Given Tails has booted without network from a USB drive with a persistent partition and stopped at Tails Greeter's login screen
    And I shutdown Tails and wait for the computer to power off
    And I setup a filesystem share containing sample videos
    And I start Tails from USB drive "current" with network unplugged and I login with persistence enabled
    And I copy the sample videos to "/home/amnesia/Persistent" as user "amnesia"
    And I copy the sample videos to "/home/amnesia/.gnupg" as user "amnesia"
    And I shutdown Tails and wait for the computer to power off
    And I start Tails from USB drive "current" with network unplugged and I login with persistence enabled
    And the file "/home/amnesia/Persistent/video.mp4" exists
    When I open "/home/amnesia/Persistent/video.mp4" with Totem
    Then I see "SampleLocalMp4VideoFrame.png" after at most 10 seconds
    Given I close Totem
    And the file "/home/amnesia/.gnupg/video.mp4" exists
    When I try to open "/home/amnesia/.gnupg/video.mp4" with Totem
    Then I see "TotemUnableToOpen.png" after at most 10 seconds
