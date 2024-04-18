# Shell Tutor - ITiCSE 2024 Release

This repository is dedicated to sharing the Shell Tutor library and the assignments created with it. The Shell Tutor code shared here is the current state as of April 2024. The assignments and engine code in this repository are not guaranteed to be receiving any future updates. Slight documentation updates may occur, and information pointing to more up-to-date releases will be shared here. 

# Contact Information

* 	Jaxton Winder
	*	Description: Lead author of the publication "The Shell Tutor: An Intelligent Tutoring System For The UNIX Command Shell And Git." Assisted with development of the Shell Tutor since its creation in 2020.
	*	Email: `jaxton DOT winder AT gmail DOT com`
	* 	GitHub: https://github.com/jaxtonw
*	Erik Falor
	*	Description: Creator of the Shell Tutor. Professional Practice Assistant Professor at Utah State University and teaches classes utilizing lessons created with the Shell Tutor. Co-author of the publication "The Shell Tutor: An Intelligent Tutoring System For The UNIX Command Shell And Git."
	*	Email: `erik DOT falor AT usu DOT edu`
	*	GitHub: https://github.com/fadein

# Quick Start

To begin running Shell Tutor lessons, clone this repository, `cd` into `assn0-intro`, and execute `./tutorial.sh` to begin the introductory Shell Tutor lessons. 

```bash
$ git clone https://github.com/jaxtonw/sigcse2024-shell-tutor
$ cd sigcse2024-shell-tutor
$ cd assn0-intro
$ ./tutorial.sh
```


# Provided Shell Tutor Assignments

## Introduction - Assignment 0

Teaches command shell fundamentals and project structures used in the CS 1440 course. Teaches basic fundamentals of Git and assists a student in setting up an SSH key.  

Located in [`assn0-intro`](./assn0-intro/).


## Shell Shortcuts And Redirection - Assignment 1

Teaches some command shell shortcuts and shell output redirection.

Located in [`assn1.1-shortcuts+redirection`](./assn1.1-shortcuts+redirection/).


## Intermediate Git - Assignment 2

Teaches the basics of Git tagging, and has students use `git tag` to place tags on an existing Git repository. 

Located in [`assn2.1-intermediate-git`](./assn2.1-intermediate-git/).


## Advanced Git - Assignment 3

Teaches the basics of time travel with Git (using `git checkout`) and basic Git branching. 

Located in [`assn3.1-advanced-git`](./assn3.1-advanced-git/).


# Shell Tutor Library

The library which powers the Shell Tutor is located in the [`lib`](./lib) directory. 


## Basic Lesson Writing Instructions
When we create lessons with the Shell Tutor, we include this `lib` directory in the released repository, conventionally named `.lib` to hide it from users.

The following lines of code are added to the beginning of a lesson file to connect the given file to the Shell Tutor and ensure the shell which executes the code is compatible with the tutor.

```sh
# Ensure shell executing this lesson is compatible with Shell Tutor
. .lib/shell-compat-test.sh 

# Put tutorial library files into $PATH
PATH="$PWD/.lib:$PATH"
```

One may then source select library files to provide necessary functionality for the lesson to be written. It is recommended to add at least the following lines immediately following the prior code.

```bash
source ansi-terminal-ctl.sh
source progress.sh
if [[ -n $_TUTR ]]; then
	source generic-error.sh
	source noop.sh
	source platform.sh
fi
```

For lessons that utilize Git, it is recommended to `source git.sh` as well.

One may then define the `setup` and `cleanup` functions and any other lesson functions. 

At the end of the file, one sources the `main.sh` script and calls the `_tutr_begin` function, declaring all lesson steps that are 


### Note About Shell Level Structure

For the Shell Tutor to both allow a student full control over the command shell and properly clean itself up upon the completion of a lesson, the Shell Tutor has to spawn *two* shells upon startup. This can lead to unexpected behaviors in certain circumstances. When writing Shell Tutor lessons, it is advised to understand which shell written code will be executed within.

```
Shell Level 0
| The shell which launches the Shell Tutor lesson. Upon completion of the Shell Tutor, the user 
| will return to this shell.  
|
--- Shell Level 1 
  | The intermediary Shell Tutor shell. Performs setup/cleanup operations. Upon startup of a 
  | lesson, it will read through the entire lesson, defining all functions and executing 
  | **all code that is not in a function or guarded by an 'if [[ -n $_TUTR ]]' block**.
  | 
  | Will execute the lesson specific 'setup' and 'cleanup' functions. Upon defining the lesson 
  | steps and executing main.sh, the next shell is spawned. By convention, this shell should *not*
  | have its directory changed from the startup location to ensure proper cleanup.
  | 
  | Code written in the lesson file after the execution of `source main.sh && _tutr_begin ...` 
  | WILL be executed once the Shell Tutor returns to this shell, and the $_TUTR variable will be 
  | defined from this point on. It is NOT advised to write any code after the 
  | `source main.sh && _tutr_begin ...` code in a lesson file for this reason.
  |     
  --- Shell Level 2
    | The shell which the student uses to interact with the lesson. Runs the Shell Tutor 'engine' 
	| while a user is interacting with a lesson. Performs step validation tasks and executes all 
	| functions corresponding to a specific lesson step. 
	| 
	| The precmd and prexec hooks which the step validation and logging code attach to are within
	| this shell. Upon completion of a lesson *or* otherwise exiting of this shell, the Shell Tutor
	| returns to shell level 1 for cleanup tasks.
```

As seen in [Basic Lesson Writing Instructions](#basic-lesson-writing-instructions), we can ensure that select code defined outside of a function is only executed at shell level two by guarding it within an `if [[ -n $_TUTR ]]` block. The example shown above ensures only select engine functionality exists within the Shell Tutor's Level 2 shell. Conversely, if one wants to execute lesson code only in shell level 1, one could guard the code within an `if [[ -z $_TUTR ]]` block.