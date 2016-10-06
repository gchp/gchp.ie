---
layout: post
title: "Discovering git-cherry"
date: 2016-08-02T13:54:37+01:00
tags: git workflow productivity
---

Today I discovered the `git cherry` command which lets you view the commits
from one branch which have not been picked into another.

Using it is pretty simple:

```bash
git checkout my-branch
git cherry <upstream> <head>
```

Where `<upstream>` is the base branch, and `<head>` is the branch containing the
additional commits.

Lets see a small example. Create a new directory, and inside it create a new 
git repo. We will also create an empty file, and commit it:

```bash
mkdir cherry-test && cd cherry-test
git init
touch file.txt
git add file.txt
git commit -m "First commit"
```

Now that we have a commit, let's create a new branch off master:

```bash
git branch develop
```

This `develop` branch will now have the single commit ("First commit" from above).
Still on master, lets create another file, and commit that too:

```bash
touch another_file.txt
git add another_file.txt
git commit -m "Second commit"
```

This leaves us in the place where we have a commit on master, which has not
yet been cherry-picked onto our "develop" branch. Now, if we checkout the `develop`
branch (`git checkout develop`), we can use `git cherry` to view the commits
which we can cherry-pick (in our case, just the one):

```bash
git cherry develop master
```

This will show all the commits we have not yet cherry-picked from master into
develop. The output is something like:

```bash
$ git cherry develop master
+ 722610c62760255e587bc8fec91b917550f38e77
```

Notice the `+` at the start. This indicates that the commit has not yet been
cherry-picked. If we were to cherry-pick this commit and re-run `git cherry` as
above, we would see the same ID prefixed with `-` instead of `+` indicating
that the commit has been cherry-picked already.

Viewing commit IDs on their own doesn't give us a whole lot of information. We
can add the `-v` option to `git cherry` to include the subject of each commit
in the output:

```bash
$ git cherry develop master
+ 722610c62760255e587bc8fec91b917550f38e77 Second commit
```

Now we can see our message "Second commit" from earlier is displayed alongside
the ID. From here we can use `git show` to view more information about any
particular commit in the list.

---

You can run `man git-cherry` to read more about this command. It's super useful,
and I wish I knew about it before now!
