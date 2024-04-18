# CS 1440 Assignment 1.1: Shortcuts and Redirection Shell Tutor


## Quick Start

*In these code examples a dollar sign `$` represents the shell's prompt.  It is shown to distinguish commands that you type from the output they produce. Do not type the `$` when you run these commands yourself.*

0.  Install Git on your computer *(Mac and Windows users: detailed instructions are below)*.
1.  Clone this repository.  Your output may be slightly different than this:
    ```
    $ git clone https://gitlab.cs.usu.edu/erik.falor/cs1440-falor-erik-assn1.1 cs1440-a1.1

    Cloning into 'cs1440-a1.1'...
    warning: redirecting to https://gitlab.cs.usu.edu/erik.falor/cs1440-falor-erik-assn1.1.git/
    remote: Enumerating objects: 40, done.
    remote: Counting objects: 100% (40/40), done.
    remote: Compressing objects: 100% (39/39), done.
    remote: Total 40 (delta 2), reused 0 (delta 0), pack-reused 0
    Receiving objects: 100% (40/40), 136.65 KiB | 1.59 MiB/s, done.
    Resolving deltas: 100% (2/2), done.
    ```
2.  Enter the `cs1440-a1.1` directory and run `./tutorial.sh`:
    ```
    $ cd cs1440-a1.1

    $ ./tutorial.sh

    Tutor: Shell Lesson #0: Shortcuts
    Tutor:
    Tutor: In this lesson you will learn how to
    Tutor:
    Tutor: * Utilize the shell's History feature to recycle previous commands
    Tutor: * Employ Line Editor shortcuts to easily navigate and change command lines
    Tutor: * Unleash the power of Tab completion
    Tutor:
    Tutor: This lesson takes around 20 minutes.
    ```
3.  When you reach the end of the lesson **do not close the terminal** until you see the message `Run ./tutorial.sh to start the next lesson`.
4.  **Mac and Windows users**: find your special installation instructions down below.


## Command Logging

The Shell Tutor makes **session logs** of your activity during lessons.  Session logs contain commands you ran, the Shell Tutor's state, and other details about your environment. *Session logs are not used for grading*.  They're used to improve the tutor, identify tough lessons, and guide enhancements.  The logs are confidential, and are seen only by your instructor and the developers unless you consent to share further.  At the end of the final lesson, the tutor will help you submit these logs to your instructor.

If you have any questions about command logging, please contact Jaxton Winder (email: `jaxton DOT winder AT usu DOT edu`) or Erik Falor (email: `erik DOT falor AT usu DOT edu`).

## Lesson Contents

*   **0-shortcuts.sh** (20 minutes)
    * Utilize the shell's History feature to recycle previous commands
    * Employ Line Editor shortcuts to easily navigate and change command lines
    * Unleash the power of Tab completion
*   **1-redirection.sh** (20 minutes)
    * How to redirect command output into a file
    * How to append output to a file
    * What STDOUT and STDERR mean to your programs
    * How to print text to STDOUT or STDERR in Python
    * How to hide unwanted command output
*   **2-submit.sh** (5 minutes)
    * This lesson helps you make and submit your certificate

## Hints

*   Interact with the tutor through the `tutor` command.
    *   When you get lost or forget what to do next, run `tutor hint`.
*   You can leave the tutorial early by exiting the shell.  There are many ways to do this:
    *   The `exit` command
    *   The `tutor quit` command
    *   Type the End-Of-Transmission character `Ctrl-D`
*   The average duration of each lesson is displayed at startup.  If you are stuck longer than this seek help from the TAs, the CS Coaching Center, or your instructor.



## Reporting Problems

When you encounter a problem with a lesson, please make a bug report so I can fix it.

*   First, check the list of [known bugs](./BUGS.md) to make sure your bug hasn't already been reported.
*   Run one of the following commands to produce a listing of technical info:
    *   From within the lesson run `tutor bug`.
    *   If the problem kicked you out of the lesson, run `./bug-report.sh` instead.
*   Scroll up in your terminal before the problem began and, using your mouse, select text from that point all the way to the end of the command's output.
*   Copy and paste that text into an email message.  Include these details:
    -   Which lesson you are/were running
    -   Which step of the lesson you were on
    -   The instructions for that step
    -   The command you ran
    -   The erroneous output
    -   The output of the bug report command
*   Send this email to `erik DOT falor AT usu DOT edu`.
    *   It is best to not send screenshots; plain text is much easier for me to work with.


## Submitting Your Work For Credit (CS 1440 Students)

*   You do not submit your work to Canvas in this class.
*   The final lesson in the tutorial teaches you how to turn your in work with Git.
*   Because you will not have any evidence of completion until the very end of the tutorial, this assignment is graded on a **pass/fail** basis.
    *   The only thing you are graded on is *honest completion of the tutorial*.
    *   Your grade does not depend on *speed* or *accuracy*.
        *   You don't get a higher score for using fewer commands.
        *   Nor is your score reduced if it takes you multiple attempts to finish a lesson.
*   One of the files that you will submit is a log of commands that you ran during the tutorial.
    *   This data helps identify parts of the tutorial that are confusing or buggy.
    *   The contents of this log do not affect your grade; **this is a pass/fail assignment**.


## Special Instructions For **macOS** Users

### How to open the Terminal app

0.  Press `Command + Space` to open Spotlight Search
1.  Type `Terminal` into the search window and click the entry with black square icon


### Default interactive shell message

The first time you open the Terminal app you may see this message:

```
The default interactive shell is now zsh.
To update your account to use zsh, please run `chsh -s /bin/zsh`.
For more details, please visit https://support.apple.com/kb/HT208050.
```

If this happens to you, run the command as instructed.  You will be prompted to enter your password:

```bash
$ chsh -s /bin/zsh
Changing shell for fadein.
Password for fadein:
```

Finally, close and re-open the Terminal app.


### Installing `git` and `python3`

If you haven't yet installed the command line developer tools, you will be greeted by a pop up asking you to install them the first time you try to run `git` or `python3`.  Just click `Install`, accept the license, and you're off to the races.


### Keyboard shortcuts

Keyboard shortcuts were introduced in the [introductory Shell Tutor](https://gitlab.cs.usu.edu/erik.falor/shell-tutor) lesson **4-projects.sh** which use both the `Control` and `Option` keys.  By default, the `Option` key does not do what is needed.  Follow these steps to set it up:

*   Launch the Terminal app
*   Open the `Terminal` menu and select `Preferences`
*   Select the `Profiles` page
*   Select the `Keyboard` tab
*   Check 'Use Option as Meta Key'

You do not need to restart the Terminal app for this setting to take effect.


## Special Installation Instructions For **Git for Windows** Users

**Not to be confused with _Windows Subsystem For Linux (WSL)_.  CS 1440 students should use Git for Windows instead of WSL.**


### Installing Git for Windows

*CS 1440 students: there is a video on Canvas that walks you through this process*

0.  Visit [https://gitforwindows.org/](https://gitforwindows.org/)
1.  Click the **Download** button, which will redirect you to a page on GitHub.com
2.  Scroll down to the *Assets* section and find the Git 64-bit executable installer
    *   Look for a filename that matches the pattern `Git-###-64-bit.exe`, where `###` stands in for a dotted version number.
3.  Locate and run the installer program on your computer.
4.  You will be presented with several options.  By and large you should keep the defaults, but keep a close eye out for these ones:
    *   *Choosing the default editor used by Git*
        -   Select the Nano editor, which is at the very top of the drop-down list (scroll up to see it)
    *   *Choose a credential helper*
        -   Select `None`
    *   *Configuring experimental options*
        -   Enable experimental support for pseudo consoles
5.  If you missed one of these options, re-run the installer to try again


### How To Open The Git+Bash Terminal

There are two ways to open the terminal:

0.  Press the Windows key or click the Start menu, then type "Git Bash" to locate the app
1.  Right-click the desktop or a folder and select "Open Git Bash here" from the menu


