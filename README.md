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

