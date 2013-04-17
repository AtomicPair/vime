# Contributing to Vime

## Reporting Bugs

1. Update to the most recent master release; we may have already resolved the bug in question.

2. Search for similar issues on the [Issues page][IssuesLink]; we may have already identified the bug.

3. Once you have confirmed that a similar bug has not already been reported to the project, open a new ticket on the [Issues page][IssuesLink].  Make sure you provide as much detail as you can about the issue, including suspect code samples, error logs, and/or screenshots.  If you'd rather take matters into your own hands, you can always fix the bug yourself and then submit a pull request with the appropriate code patches (jump down to the *"Contributing Code"* section).

4. The project team will work with you until your issue can be verified.  Once verified, a team member will flag the issue appropriately and update the ticket with any progress updates through the [Issues page][IssuesLink].

5. When the bug is fixed, we will mark the bug as `fixed` and commit the code patches back to the master repository.

6. Before we can close the ticket, we will need you to merge the fix(es) back into your repository and confirm that the bug has been resolved on your local machine.  Once you have confirmed resolution, we will close the ticket in the Issues tracker.  *(Note: If your ticket remains marked as `fixed` but unconfirmed by you for more than 30 days, we will automatically close the ticket.)*

## Requesting New Features

1. Before submitting new features, hop over to the project's [Issues page][IssuesLink] and filter the issues list for all new features using the `feature` label.  Review this list for similar feature requests.  It's possible somebody has already asked for the same feature or provided a pull request that we're still discussing.

2. Once you have confirmed that a similar request has not already been submitted to the project, open a new Issues ticket and tag it with the `feature` label.  Provide a clear and detailed explanation of the feature you want to see in Vime, including the reasons why you think the feature should be included in the project roadmap.  The more information you give us, the more you will help us understand the size, scope, and benefit of the feature you are requesting.

3. If you're an awesome developer, why not build the feature yourself and then submit a pull request back to the repository (refer to the *"Contributing Code"* section below)?  :-)

## Contributing Code

1. Clone the repo:

  ```
  git clone git://github.com/Axianator/Vime.git
  ```

2. Create a new branch:

  ```
  cd Vime
  git checkout -b new_vime_branch
  ```

3. Code, code, code!

  This is where the magic happens.  However, before you create any new code (or modify any existing code), make sure you first read the [Vime Style Guide][StyleGuideLink] and [Vime Developers Guide][DeveloperLink].  Following the guidelines laid out in these two documents will greatly reduce the amount of time it may take to review and accept your submissions into the master repository.

5. Commit your code:

  ```
  git commit -a
  ```

  **Note: Do not leave the commit message blank!** Always provide a detailed description of your commit!

6. Update your branch:

  ```
  git checkout master
  git pull --rebase
  ```

7. Fork:

  ```
  git remote add mine git@github.com:<your user name>/Vime.git
  ```

8. Push to your remote:

  ```
  git push mine new_vime_branch
  ```

9. Issue a Pull Request

  * Navigate to the Vime repository you just pushed to (e.g. https://github.com/your-user-name/vime)
  * Click "Pull Request".
  * Write your branch name in the branch field (this is filled with "master" by default)
  * Click "Update Commit Range".
  * Ensure the changesets you introduced are included in the "Commits" tab.
  * Ensure that the "Files Changed" incorporate all of your changes.
  * Fill in some details about your potential patch including a meaningful title.
  * Click "Send pull request".

Once you have completed these steps, the Vime team will review your request and issue appropriate feedback.

[DeveloperLink]: https://github.com/Axianator/Vime/blob/master/docs/DEVELOPERS.md
[IssuesLink]: https://github.com/Axianator/Vime/issues
[StyleGuideLink]: https://github.com/Axianator/Vime/blob/master/docs/STYLE-GUIDE.txt

