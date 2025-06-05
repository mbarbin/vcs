First we need to setup a repo in a way that satisfies the test environment. This
includes specifics required by the GitHub Actions environment.

  $ volgo-vcs init -q .
  $ volgo-vcs set-user-config --user.name "Test User" --user.email "test@example.com"

  $ cat > hello << EOF
  > Hello World
  > EOF

  $ cat hello
  Hello World

  $ volgo-vcs add hello
  $ rev0=$(volgo-vcs commit -m "Initial commit")

Making sure the branch name is deterministic.

  $ volgo-vcs rename-current-branch main

Rev-parse.

  $ git rev-parse HEAD | sed -e "s/$rev0/rev0/g"
  rev0

  $ volgo-vcs current-revision | sed -e "s/$rev0/rev0/g"
  rev0

  $ volgo-vcs current-branch
  main

  $ volgo-vcs branch-revision | sed -e "s/$rev0/rev0/g"
  rev0

  $ volgo-vcs branch-revision main | sed -e "s/$rev0/rev0/g"
  rev0

  $ volgo-vcs branch-revision unknown-branch
  Error: Branch not found. (branch_name unknown-branch)
  [123]

Testing a successful file show with git and via vcs.

  $ git show HEAD:hello
  Hello World

  $ volgo-vcs show-file-at-rev hello -r $rev0
  Hello World

Invalid path-in-repo.

  $ volgo-vcs show-file-at-rev /hello -r $rev0
  Error: Path is not in repo. (path /hello)
  [123]

File system operations.

  $ volgo-vcs read-dir untracked
  Context:
  (Vcs.read_dir
   (dir
    $TESTCASE_ROOT/untracked))
  Error:
  (Sys_error
   "$TESTCASE_ROOT/untracked: No such file or directory")
  [123]

  $ mkdir -p untracked

  $ volgo-vcs read-dir untracked
  ()

  $ echo "New untracked file" | volgo-vcs save-file untracked/hello

  $ volgo-vcs read-dir untracked
  (hello)

  $ volgo-vcs read-dir untracked/hello
  Context:
  (Vcs.read_dir
   (dir
    $TESTCASE_ROOT/untracked/hello))
  Error:
  (Sys_error
   "$TESTCASE_ROOT/untracked/hello: Not a directory")
  [123]

  $ volgo-vcs load-file untracked/hello
  New untracked file

  $ chmod -r untracked
  $ volgo-vcs read-dir untracked
  Context:
  (Vcs.read_dir
   (dir
    $TESTCASE_ROOT/untracked))
  Error:
  (Sys_error
   "$TESTCASE_ROOT/untracked: Permission denied")
  [123]

  $ rm untracked/hello
  $ rmdir untracked

Find enclosing repo root.

  $ (cd "/" && volgo-vcs current-revision)
  Error: Failed to locate enclosing repo root from directory. (from /)
  [123]

  $ volgo-vcs find-enclosing-repo-root
  .git: $TESTCASE_ROOT

  $ mkdir subdir
  $ volgo-vcs find-enclosing-repo-root --from subdir
  .git: $TESTCASE_ROOT

  $ volgo-vcs find-enclosing-repo-root --from "/"

  $ mkdir -p subdir/hg/otherdir
  $ touch subdir/hg/.hg

  $ volgo-vcs find-enclosing-repo-root --from subdir/hg/otherdir
  .git: $TESTCASE_ROOT

  $ volgo-vcs find-enclosing-repo-root --from subdir/hg/otherdir --store .hg
  .hg: $TESTCASE_ROOT/subdir/hg

Adding a new file under a directory.

  $ mkdir dir
  $ echo "New file" > dir/hello

  $ volgo-vcs add dir/hello
  $ rev1=$(volgo-vcs commit -m "Added dir/hello")

  $ volgo-vcs ls-files
  dir/hello
  hello

  $ volgo-vcs ls-files --below dir
  dir/hello

  $ volgo-vcs ls-files --below /dir
  Error: Path is not in repo. (path /dir)
  [123]

  $ volgo-vcs ls-files --below foo
  Context:
  (Vcs.ls_files
   (repo_root
    $TESTCASE_ROOT)
   (below foo))
  ((prog /usr/bin/git) (args (ls-files --full-name)) (exit_status Unknown)
   (cwd
    $TESTCASE_ROOT/foo)
   (stdout "") (stderr ""))
  Error:
  "Unix.Unix_error(Unix.ENOENT, \"open\", \"$TESTCASE_ROOT/foo\")"
  [123]

Testing an unsuccessful file show with git and via vcs.

  $ git rm hello
  rm 'hello'

  $ git commit -q -m "Removed hello"
  $ rev2=$(git rev-parse HEAD)

  $ volgo-vcs show-file-at-rev hello -r $rev2 2>&1 | sed -e "s/$rev2/rev2/g"
  Path 'hello' does not exist in 'rev2'

Name status.

  $ volgo-vcs name-status $rev0 $rev2
  ((Added dir/hello) (Removed hello))

Num status.

  $ volgo-vcs num-status $rev0 $rev2
  (((key (One_file dir/hello))
    (num_stat (Num_lines_in_diff ((insertions 1) (deletions 0)))))
   ((key (One_file hello))
    (num_stat (Num_lines_in_diff ((insertions 0) (deletions 1))))))

Stabilize output.

  $ stabilize_output() {
  >   sed -e "s/$rev0/\$REV0/g" -e "s/$rev1/\$REV1/g" -e "s/$rev2/\$REV2/g"
  > }

Refs.

  $ volgo-vcs refs | stabilize_output
  (((rev $REV2)
    (ref_kind (Local_branch (branch_name main)))))

Log.

  $ volgo-vcs log | stabilize_output
  ((Commit (rev $REV2)
    (parent $REV1))
   (Commit (rev $REV1)
    (parent $REV0))
   (Root (rev $REV0)))

Graph.

  $ volgo-vcs graph | stabilize_output
  ((refs (($REV2 refs/heads/main)))
   (roots ($REV0))
   (leaves (($REV2 (refs/heads/main)))))

Greatest common ancestors.

  $ volgo-vcs gca
  ()

  $ volgo-vcs gca $rev1 | stabilize_output
  ($REV1)

  $ volgo-vcs gca $rev1 $rev2 | stabilize_output
  ($REV1)

  $ volgo-vcs gca $rev1 2e9ab12edfe8e3a01cf2fa2b46210c042e9ab12e
  Error: Rev not found. (rev 2e9ab12edfe8e3a01cf2fa2b46210c042e9ab12e)
  [123]

Descendance.

  $ volgo-vcs descendance $rev1 $rev1
  Same_node

  $ volgo-vcs descendance $rev1 $rev2
  Strict_ancestor

  $ volgo-vcs descendance $rev2 $rev1
  Strict_descendant

  $ volgo-vcs descendance $rev1 2e9ab12edfe8e3a01cf2fa2b46210c042e9ab12e
  Error: Rev not found. (rev 2e9ab12edfe8e3a01cf2fa2b46210c042e9ab12e)
  [123]

Vcs allows to run the git command line directly if the backend supports it.

  $ volgo-vcs git rev-parse HEAD | stabilize_output
  $REV2

  $ volgo-vcs git invalid-command 2> /dev/null
  [1]

Worktrees. We check against a regression where the repo root of worktrees was
not correctly computed. Below we create a worktree at a specific revision and
verify that the list of files accurately reflects the state of the tree at that
revision.

  $ mkdir .worktree
  $ volgo-vcs git worktree add .worktree/rev1 $rev1 > /dev/null 2> /dev/null

  $ (cd .worktree/rev1 ; volgo-vcs ls-files)
  dir/hello
  hello

  $ volgo-vcs ls-files
  dir/hello

  $ volgo-vcs git worktree remove .worktree/rev1

Vcs's help for review.

  $ volgo-vcs --help=plain
  NAME
         volgo-vcs - call a command from the vcs interface
  
  SYNOPSIS
         volgo-vcs COMMAND …
  
          
  
         This is an executable to test the Version Control System (vcs)
         library.
  
          
  
         We expect a 1:1 mapping between the function exposed in the [Vcs.S]
         and the sub commands exposed here, plus additional ones.
  
          
  
  COMMANDS
         add [OPTION]… file
             add a file to the index
  
         branch-revision [OPTION]… [BRANCH]
             revision of a branch
  
         commit [--message=MSG] [--quiet] [OPTION]…
             commit a file
  
         current-branch [OPTION]…
             current branch
  
         current-revision [OPTION]…
             revision of HEAD
  
         descendance [OPTION]… REV REV
             print descendance relation between 2 revisions
  
         find-enclosing-repo-root [--from=path/to/dir] [--store=VAL]
         [OPTION]…
             find enclosing repo root
  
         gca [OPTION]… [REV]…
             print greatest common ancestors of revisions
  
         git [OPTION]… [ARG]…
             run the git cli
  
         graph [OPTION]…
             compute graph of current repo
  
         init [--quiet] [OPTION]… path/to/root
             initialize a new repository
  
         load-file [OPTION]… path/to/file
             print a file from the filesystem (aka cat)
  
         log [OPTION]…
             show the log of current repo
  
         ls-files [--below=PATH] [OPTION]…
             list file
  
         name-status [OPTION]… BASE TIP
             show a summary of the diff between 2 revs
  
         num-status [OPTION]… BASE TIP
             show a summary of the number of lines of diff between 2 revs
  
         read-dir [OPTION]… path/to/dir
             print the list of files in a directory
  
         refs [OPTION]…
             show the refs of current repo
  
         rename-current-branch [OPTION]… branch
             move/rename a branch to a new name
  
         save-file [OPTION]… FILE
             save stdin to a file from the filesystem (aka tee)
  
         set-user-config [--user.email=EMAIL] [--user.name=USER] [OPTION]…
             set the user config
  
         show-file-at-rev [--rev=REV] [OPTION]… FILE
             show the contents of file at a given revision
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         volgo-vcs exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
