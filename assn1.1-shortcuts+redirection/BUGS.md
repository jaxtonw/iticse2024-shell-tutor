# Known Bugs

Creating software is a delicate balancing act; fixing or preventing bugs comes at a cost.  When I have to make a tough call about a bug, I consider what will be best for my *target audience*: a new shell user with a basic Bash or Zsh installation.

These are bugs that haven't been fixed yet or cannot be fixed without compromising the experience of my target audience:

*   **macOS and Windows accept filenames case-insensitively, while the tutor is case sensitive**
    *   You should match the spelling reported by the `ls` command when entering file names
    *   Case insensitivity is a "feature" of those OSes, and is difficult to work around in the shell
*   **GNU long options are not accepted**
    *   Multiple commands can generate the correct output, fulfilling the tutor's requirements. For instance, in Lesson 1, step 13, any of the following commands could be used:
        *   `ls -r1t`
        *   `ls -rt1`
        *   `ls -r -1 -t`
        *   `ls -r -t -1`
        *   `ls -r1 -t`
        *   `ls -r -t1`
        *   ... and so on for 24 permutations
    *   Advanced shell users are aware of even more ways to produce the expected output through the use of *long options*. The above command could also be written as `ls --width=1 --reverse --time=use` with the options appearing in any order.  However, commands of this from are not accepted.
    *   The tutor does not accept long options because:
        *   Correctly recognizing them increases the complexity of the tutor's code by a large factor
        *   Long options don't work on all systems (particularly macOS); supporting them makes the tutor much more complex with no benefit to those users
        *   Very few students are even aware of long options; supporting them makes the tutor much more complex with no benefit to most students
    *   A satisfactory solution amounts to rewriting significant portions of the tutor to make an improvement that only two or three people will notice; I've chosen to spend my time creating more lessons instead
*   **The tutor doesn't work with Fish, Ksh, Csh, Bourne Shell, Oil, Ash, Dash, PowerShell, CMD.exe, etc.**
    *   I have deliberately chosen Bash and Zsh because they are the shells a beginner is most likely to encounter, and because they are the easiest for me to support
    *   If you know about these other shells, you aren't my target audience
*   **The progress bar doesn't work with my cool Zsh theme**
    *   Ah, a Powerlevel 10k user?  You aren't exactly my target audience ;)
    *   The way these fancy shell themes manage your `$PS1` is incompatible with the shell tutor
        *   The progress bar is merely a decoration; the lessons should still work in your fancy shell (let me know if they don't)
    *   Other options:
        1.  You may be able to find a way to add `$(_tutr_statusbar $_I $_MAX_STEP $(basename $_TUTR))` to your theme
        2.  You can run `tutor where` to check your progress
        3.  Or, you can temporarily disable p10k while working on the lessons
    *   The Apollo 11 mission computer took astronauts to the moon with 2kb of RAM.  p10k's `$PS1` variable is around 6kb, and the project has nearly 5MB of code.  These facts aren't relevant, but they amuse me.
