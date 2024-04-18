# Known Bugs

0.  *Windows* `git help tag` does display the manual to some users
    *   It should pop a browser tab to https://git-scm.com/docs/git-tag, but this isn't happening for some users
    *   **Workaround** directly browse to https://git-scm.com/docs/git-tag
1.  The tutorial should inspect the exit status of `git push/pull/clone` commands.  If the GitLab server is restarted right when a student runs one of these commands, the message "Internal API unreachable"is displayed and Git exits with status 128.  The lesson proceeds as if nothing went wrong.
