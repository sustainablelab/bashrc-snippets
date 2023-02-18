Snippets of helpful stuff I put in `~/.bashrc`.

Below are some common commands that I forget:

# Count files

```bash
# Count number of files AND folders in the pwd
ls | wc -l

# Count number of FOLDERS in pwd
ls -p | grep / | wc -l

# Count number of FILES in pwd
ls -p | grep -v / | wc -l
```

# Show file size

```bash
# Size of the pwd
du -sh .

# Size of each file AND folder in the pwd
du -sh *

# Size of each FOLDER in the pwd
du -sh $(ls -p | grep /)

# Size of each FILE in the pwd
du -sh $(ls -p | grep -v /)
```


Below is a quick tutorial on Bourne Shell scripting:

# Use `git -C` and `sh` script

## `git -C`

`git -C` is an alternative to repeatedly doing `cd` in and out of
repo directories.

For example, I like to use submodules. Say I have a submodule
`mike-libs` in my current repo, then I often do this to see if
there are changes:

```
git -C mike-libs/ fetch
git -C mike-libs/ status
```

And then if there are, I probably want to pull them in:

```
git -C mike-libs/ pull
```

Another common case for `-C` is I like to put lots of repos in
the same folder (`~/gitrepos`). For embedded work using Mbed
Studio to build with the Arm C6 compiler, I have an
`arm-workspace` folder so that I can access all my projects from
a single *workspace* in Mbed Studio.

I often want to run the above Git commands on every repo in some
folder, like my `arm-workspace` folder. Use Bourne Shell
scripting.

## Bourne Shell script

My goal is to use `-C` to run some git command on every folder in
the `pwd`.

I have lots of projects in my `arm-workspace`, plus some random
files that are not projects:

```bash
$ cd arm-workspace/
$ ls
adc-load_step                     display-a      sensors-a  ttn-a
argh                              display-debug  sensors-b  ttn-b
compile-config-m-XDOT_L151CC.txt  lwt-a          serial-a   ttn-c
```

Check status on all of them to see which are dirty:

```bash
$ for f in *; do git -C $f status; done
```

That is the bare minimum command. It leaves a lot of
functionality to be desired, like:

- tell me which repo the status is for
- only run the command on folders

Below I build up a better version of this command, adding
functionality one bit at a time:

```bash
# Bare essentials
$ for f in *; do git -C $f status; done

# Print repo name
$ for f in *; do printf "\n---%s---\n" $f; git -C $f status; done

# Only do this if $f is a directory
$ for f in *; do if [ -d $f ]; then printf "\n---%s---\n" $f; git -C $f status; fi; done

# Same as previous, but with terse syntax (eliminates 'if' and 'then')
$ for f in *; do [ -d $f ] && printf "\n---%s---\n" $f && git -C $f status; done
```

*Explaining all of the above...*

Bourne Shell script for loop:

- `for f in *` : variable `f` takes on the name of each thing
  (folder or file) in the `pwd`
- `;` just lets me put this `sh` script on one line
    - a tip to figure out where `;` is necessary:
        - enter each line of the command at the shell
        - hit Enter after each line
        - shell automatically puts a `>` prompt
        - once the command is done being entered, the shell
          evaluates it
        - now hit the Up Arrow
        - the command is stored in history as a single command
          with the semicolon `;` style
        - this is particularly helpful to remember the convoluted
          if-statement syntax
- `do` : this is the body of the *for loop*
    - I put whatever commands I want here and separate them with `;`
- `done` : body of the *for loop* is done

Body of the for loop:

- `printf` : prefer this over `echo`
    - `echo` behavior is not consistent (depends user profile settings)
    - I am already familiar with `printf` because I write a lot of C
    - just enter command `printf` on its own to see the usage
- `git -C $f status` : `$f` is the folder name, so this is just
  like doing `git -C sensors-a status` 
- `[ -d $f ]` : evaluates to 0 (which means command ran OK) if
  `$f` is a directory
    - this is alternate syntax for the `test` command:
    - `test -d folder_bob ; echo $?`
        - returns 0 (OK) if `folder_bob` is a directory and it
          exists
        - returns 1 (FAIL) if `folder_bob` does not exist
        - returns 1 (FAIL) if `folder_bob` is not a directory
    - `[ -d folder_bob] ; echo $?`
        - this behaves exactly the same
    - `-d` is one of many flags you can test
    - run `help test` to see them all
    - run `help [` to see that `[ arg... ]` is a synonym for the
      "test" builtin

- chaining commands with `&&` instead of `;`
    - this replaces the `;`
    - chaining commands with `;` means execute next command
      regardless of how previous command ran
    - chaining commands with `&&` means only execute next
      command if previous command succeeded
    - chaining commands with `||` means only execute next command
      if previous command failed
- `&&` replaces `if` and `then`
    - chaining commands with `&&` means subsequent commands only
      run if the previous succeeded
    - that's what the `if` and `then` statements do
    - so these are logically equivalent

So `test -d $f` (or `[ -d $f ]` ) eliminates files. But say I
have a folder that is not a Git repo:

```bash
$ mkdir not-a-repo
$ git -C not-a-repo/ status
fatal: not a git repository (or any of the parent directories): .git
$ echo $?
128
```

Compare the return value when a folder *is* a Git repo:

```bash
$ git -C sensors-a/ status
On branch master
Your branch is up to date with 'origin/master'.
$ echo $?
0
```

This is similar to the `[ -d $f]` return value:

- `0` means success
- non-zero means failure

So, how can I use this to only print `git status` output when the
folder is an actual Git repo?

The trouble is that `git status` prints, it doesn't just check
status and set a return value. So I can't use the exact same
trick as before with `[ -d $f ]`.

But if the return value is non-zero, the print goes to `stderr`,
not `stdout`. So I can redirect the `stdout` stream to
`/dev/null`.

If the folder is a Git repo, I get the same output as before:

```bash
$ git -C sensors-a/ status 2> /dev/null 
On branch master
Your branch is up to date with 'origin/master'.
```

If the folder is *not* a Git repo, I get no output:

```bash
$ git -C not-a-repo/ status 2> /dev/null 
```

Now I have this Bourne Shell script:

```bash
$ for f in *; do [ -d $f ] && printf "\n---%s---\n" $f && git -C $f status 2> /dev/null; done
```

I've fixed the problem of running `git status` on non-Git repo
folders, but I still print the name of folders that are not Git
repos. So use the same trick and chain a `git status` upstream of
the `printf`:

```bash
$ for f in *; do [ -d $f ] && git -C $f status > /dev/null 2>&1 && printf "\n---%s---\n" $f && git -C $f status 2> /dev/null; done
```

Of course now I don't need to redirect the `stderr` on that
second call to `git status` because any folders that are not Git
repos are already filtered out by that first call to `git
status`.

```bash
$ for f in *; do [ -d $f ] && git -C $f status > /dev/null 2>&1 && printf "\n---%s---\n" $f && git -C $f status ; done
```

`git status` outputs too much. Use the `-s` flag.

```bash
$ for f in *; do [ -d $f ] && git -C $f status > /dev/null 2>&1 && printf "\n---%s---\n" $f && git -C $f status -s ; done

---adc-load_step---

---argh---
?? .mbed
?? Makefile
?? mbed_app.json
?? src/

---display-a---

---display-debug---

---lwt-a---
 ? dot-examples

---sensors-a---

---sensors-b---

---serial-a---

---ttn-a---

---ttn-b---

---ttn-c---
 M .gitignore
A  .gitmodules
 M src/RadioEvent.h
 M src/main.cpp
```

And that's it. Now I have a reasonable list of folders that are
git repos and whether or not those repos are dirty. I'm resisting
the urge to make the output formatted in a fancier way; this is
good enough for now.

Now turn that into a `bash alias` in my `.bashrc`:

```bash
alias gitdirty='for f in *; do [ -d $f ] && git -C $f status > /dev/null 2>&1 && printf "\n---%s---\n" $f && git -C $f status -s ; done'
```
