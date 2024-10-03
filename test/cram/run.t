First we need to setup a repo in a way that satisfies the test environment. This
includes specifics required by the GitHub Actions environment.

  $ ocaml-vcs init -q .
  $ ocaml-vcs set-user-config --user.name "Test User" --user.email "test@example.com"

  $ cat > hello << EOF
  > Hello World
  > EOF

  $ cat hello
  Hello World

  $ ocaml-vcs add hello
  $ rev0=$(ocaml-vcs commit -m "Initial commit")

Making sure the branch name is deterministic.

  $ ocaml-vcs rename-current-branch main

Rev-parse.

  $ git rev-parse HEAD | sed -e "s/$rev0/rev0/g"
  rev0

  $ ocaml-vcs current-revision | sed -e "s/$rev0/rev0/g"
  rev0

  $ ocaml-vcs current-branch
  main

  $ ocaml-vcs branch-revision | sed -e "s/$rev0/rev0/g"
  rev0

  $ ocaml-vcs branch-revision main | sed -e "s/$rev0/rev0/g"
  rev0

  $ ocaml-vcs branch-revision unknown-branch
  Error: Branch not found (branch_name unknown-branch)
  [123]

Testing a successful file show with git and via vcs.

  $ git show HEAD:hello
  Hello World

  $ ocaml-vcs show-file-at-rev hello -r $rev0
  Hello World

Invalid path-in-repo.

  $ ocaml-vcs show-file-at-rev /hello -r $rev0
  Error: Path is not in repo (path /hello)
  [123]

File system operations.

  $ ocaml-vcs read-dir untracked
  Error:
  ((steps
    ((Vcs.read_dir
      ((dir
        $TESTCASE_ROOT/untracked)))))
   (error
    ( "Eio.Io Fs Not_found Unix_error (No such file or directory, \"openat2\", \"\"),\
     \n  reading directory <fs:$TESTCASE_ROOT/untracked>")))
  [123]

  $ mkdir -p untracked

  $ ocaml-vcs read-dir untracked
  ()

  $ echo "New untracked file" | ocaml-vcs save-file untracked/hello

  $ ocaml-vcs read-dir untracked
  (hello)

  $ ocaml-vcs read-dir untracked/hello
  Error:
  ((steps
    ((Vcs.read_dir
      ((dir
        $TESTCASE_ROOT/untracked/hello)))))
   (error
    ( "Eio.Io Unix_error (Not a directory, \"openat2\", \"\"),\
     \n  reading directory <fs:$TESTCASE_ROOT/untracked/hello>")))
  [123]

  $ ocaml-vcs load-file untracked/hello
  New untracked file

  $ chmod -r untracked
  $ ocaml-vcs read-dir untracked
  Error:
  ((steps
    ((Vcs.read_dir
      ((dir
        $TESTCASE_ROOT/untracked)))))
   (error
    ( "Eio.Io Fs Permission_denied Unix_error (Permission denied, \"openat2\", \"\"),\
     \n  reading directory <fs:$TESTCASE_ROOT/untracked>")))
  [123]

  $ rm untracked/hello
  $ rmdir untracked

Adding a new file under a directory.

  $ mkdir dir
  $ echo "New file" > dir/hello

  $ ocaml-vcs add dir/hello
  $ rev1=$(ocaml-vcs commit -m "Added dir/hello")

  $ ocaml-vcs ls-files
  dir/hello
  hello
  $ ocaml-vcs ls-files --below dir
  dir/hello
  $ ocaml-vcs ls-files --below /dir
  Error: Path is not in repo (path /dir)
  [123]

Testing an unsuccessful file show with git and via vcs.

  $ git rm hello
  rm 'hello'

  $ git commit -q -m "Removed hello"
  $ rev2=$(git rev-parse HEAD)

  $ ocaml-vcs show-file-at-rev hello -r $rev2 2>&1 | sed -e "s/$rev2/rev2/g"
  Path 'hello' does not exist in 'rev2'

Name status.

  $ ocaml-vcs name-status $rev0 $rev2
  ((Added dir/hello) (Removed hello))

Num status.

  $ ocaml-vcs num-status $rev0 $rev2
  (((key (One_file dir/hello))
    (num_stat (Num_lines_in_diff ((insertions 1) (deletions 0)))))
   ((key (One_file hello))
    (num_stat (Num_lines_in_diff ((insertions 0) (deletions 1))))))

Stabilize output.

  $ stabilize_output() {
  >   sed -e "s/$rev0/\$REV0/g" -e "s/$rev1/\$REV1/g" -e "s/$rev2/\$REV2/g"
  > }

Refs.

  $ ocaml-vcs refs | stabilize_output
  (((rev $REV2)
    (ref_kind (Local_branch (branch_name main)))))

Log.

  $ ocaml-vcs log | stabilize_output
  ((Commit (rev $REV2)
    (parent $REV1))
   (Commit (rev $REV1)
    (parent $REV0))
   (Root (rev $REV0)))

Graph.

  $ ocaml-vcs graph | stabilize_output
  ((refs (($REV2 refs/heads/main)))
   (roots ($REV0))
   (tips (($REV2 (refs/heads/main)))))

Greatest common ancestors.

  $ ocaml-vcs gca
  ()

  $ ocaml-vcs gca $rev1 | stabilize_output
  ($REV1)

  $ ocaml-vcs gca $rev1 $rev2 | stabilize_output
  ($REV1)

  $ ocaml-vcs gca $rev1 2e9ab12edfe8e3a01cf2fa2b46210c042e9ab12e
  Error: Rev not found (rev 2e9ab12edfe8e3a01cf2fa2b46210c042e9ab12e)
  [123]

Vcs allows to run the git command line directly if the provider supports it.

  $ ocaml-vcs git rev-parse HEAD | stabilize_output
  $REV2

  $ ocaml-vcs git invalid-command 2> /dev/null
  [1]

Worktrees. We check against a regression where the repo root of worktrees was
not correctly computed. Below we create a worktree at a specific revision and
verify that the list of files accurately reflects the state of the tree at that
revision.

  $ mkdir .worktree
  $ ocaml-vcs git worktree add .worktree/rev1 $rev1 > /dev/null 2> /dev/null

  $ (cd .worktree/rev1 ; ocaml-vcs ls-files)
  dir/hello
  hello

  $ ocaml-vcs ls-files
  dir/hello

  $ ocaml-vcs git worktree remove .worktree/rev1

Vcs's help for review.

  $ ocaml-vcs --help=plain
  NAME
         ocaml-vcs - call a command from the vcs interface
  
  SYNOPSIS
         ocaml-vcs COMMAND …
  
          
  
         This is an executable to test the Version Control System (vcs)
         library.
  
          
  
         We expect a 1:1 mapping between the function exposed in the [Vcs.S]
         and the sub commands exposed here, plus additional ones.
  
          
  
  COMMANDS
         add [OPTION]… file
             add a file to the index
  
         branch-revision [OPTION]… [branch]
             revision of a branch
  
         commit [--message=MSG] [--quiet] [OPTION]…
             commit a file
  
         current-branch [OPTION]…
             current branch
  
         current-revision [OPTION]…
             revision of HEAD
  
         gca [OPTION]… [rev]…
             print greatest common ancestors of revisions
  
         git [OPTION]… [ARG]…
             run the git cli
  
         graph [OPTION]…
             compute graph of current repo
  
         init [--quiet] [OPTION]… file
             initialize a new repository
  
         load-file [OPTION]… file
             print a file from the filesystem (aka cat)
  
         log [OPTION]…
             show the log of current repo
  
         ls-files [--below=PATH] [OPTION]…
             list file
  
         name-status [OPTION]… rev rev
             show a summary of the diff between 2 revs
  
         num-status [OPTION]… rev rev
             show a summary of the number of lines of diff between 2 revs
  
         read-dir [OPTION]… file
             print the list of files in a directory
  
         refs [OPTION]…
             show the refs of current repo
  
         rename-current-branch [OPTION]… branch
             move/rename a branch to a new name
  
         save-file [OPTION]… file
             save stdin to a file from the filesystem (aka tee)
  
         set-user-config [--user.email=EMAIL] [--user.name=USER] [OPTION]…
             set the user config
  
         show-file-at-rev [--rev=REV] [OPTION]… file
             show the contents of file at a given revision
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ocaml-vcs exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
