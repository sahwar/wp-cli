Feature: Manage WordPress posts

  Scenario: Creating/updating/deleting posts
    Given a WP install

    When I run `wp post create --post_title='Test post' --porcelain`
    Then STDOUT should match '%d'
    And save STDOUT as {POST_ID}

    When I run `wp post update {POST_ID} --post_title='Updated post'`
    Then STDOUT should be:
      """
      Success: Updated post {POST_ID}.
      """

    When I run `wp post delete {POST_ID}`
    Then STDOUT should be:
      """
      Success: Trashed post {POST_ID}.
      """

    When I run the previous command again
    Then STDOUT should not be empty

    When I try the previous command again
    Then the return code should be 1

  Scenario: Creating/getting posts
    Given a WP install
    And a content.html file:
      """
      This is some content.

      It will be inserted in a post.
      """

    When I run `wp post create --post_title='Test post' --porcelain - < content.html`
    Then STDOUT should match '%d'
    And save STDOUT as {POST_ID}

    When I run `wp post get --format=content {POST_ID}`
    Then STDOUT should be:
      """
      This is some content.

      It will be inserted in a post.
      """

    When I run `wp post get --format=table {POST_ID}`
    Then STDOUT should be a table containing rows:
      | Field      | Value     |
      | ID         | {POST_ID} |
      | post_title | Test post |

    When I run `wp post get --format=json {POST_ID}`
    Then STDOUT should be JSON containing:
      """
      {"ID":{POST_ID},"post_title":"Test post"}
      """

  Scenario: Creating/listing posts
    Given a WP install

    When I run `wp post create --post_title='Publish post' --post_content='Publish post content' --post_status='publish' --porcelain`
    Then STDOUT should match '%d'

    When I run `wp post create --post_title='Draft post' --post_content='Draft post content' --post_status='draft' --porcelain`
    Then STDOUT should match '%d'

    When I run `wp post list --post_type='post' --fields=post_title,post_name,post_status --format=csv`
    Then STDOUT should be CSV containing:
      | post_title   | post_name    | post_status  |
      | Publish post | publish-post | publish      |
      | Draft post   |              | draft        |
