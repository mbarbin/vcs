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
  $ rev0=$(volgo-vcs commit -m "Initial commit" -o sexp)

Making sure the branch name is deterministic.

  $ volgo-vcs rename-current-branch main

Rev-parse.

  $ git rev-parse HEAD | sed -e "s/$rev0/rev0/g"
  rev0

  $ volgo-vcs current-revision | sed -e "s/$rev0/rev0/g"
  rev0

  $ volgo-vcs current-branch
  main

  $ volgo-vcs current-branch --opt
  (main)

  $ git switch --detach main 2> /dev/null

  $ volgo-vcs current-branch
  Context:
  (Vcs.current_branch
   (repo_root
    $TESTCASE_ROOT))
  Error: Not currently on any branch.
  [123]

  $ volgo-vcs current-branch --opt
  ()

  $ git checkout main
  Switched to branch 'main'

  $ volgo-vcs branch-revision | sed -e "s/$rev0/rev0/g"
  rev0

  $ volgo-vcs branch-revision main | sed -e "s/$rev0/rev0/g"
  rev0

  $ volgo-vcs branch-revision unknown-branch
  Error: Branch [unknown-branch] not found.
  [123]

Testing a successful file show with git and via vcs.

  $ git show HEAD:hello
  Hello World

  $ volgo-vcs show-file-at-rev hello -r $rev0
  Hello World

Invalid path-in-repo.

  $ volgo-vcs show-file-at-rev /hello -r $rev0
  Error: Path "/hello" is not in repo.
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
  Error: Failed to locate enclosing repo root from directory "/".
  [123]

  $ volgo-vcs find-enclosing-repo-root
  (((store .git)
    (path
     $TESTCASE_ROOT)))

  $ mkdir subdir
  $ volgo-vcs find-enclosing-repo-root --from subdir
  (((store .git)
    (path
     $TESTCASE_ROOT)))

  $ volgo-vcs find-enclosing-repo-root --from "/"
  ()

  $ mkdir -p subdir/hg/otherdir
  $ touch subdir/hg/.hg

  $ volgo-vcs find-enclosing-repo-root --from subdir/hg/otherdir --store .git
  (((store .git)
    (path
     $TESTCASE_ROOT)))

  $ volgo-vcs find-enclosing-repo-root --from subdir/hg/otherdir --store .hg
  (((store .hg)
    (path
     $TESTCASE_ROOT/subdir/hg)))

  $ volgo-vcs find-enclosing-repo-root --output-format=dyn
  Some
    { store = ".git"
    ; path =
        "$TESTCASE_ROOT"
    }

  $ volgo-vcs find-enclosing-repo-root --output-format=sexp
  (((store .git)
    (path
     $TESTCASE_ROOT)))

Adding a new file under a directory.

  $ mkdir dir
  $ echo "New file" > dir/hello

  $ volgo-vcs add dir/hello
  $ rev1=$(volgo-vcs commit -m "Added dir/hello" -o sexp)

  $ volgo-vcs ls-files
  dir/hello
  hello

  $ volgo-vcs ls-files --below dir
  dir/hello

  $ volgo-vcs ls-files --below /dir
  Error: Path "/dir" is not in repo.
  [123]

  $ volgo-vcs ls-files --below foo
  Context:
  (Vcs.ls_files
   (repo_root
    $TESTCASE_ROOT)
   (below foo))
  ((prog git) (args (ls-files --full-name)) (exit_status Unknown)
   (cwd
    $TESTCASE_ROOT/foo)
   (stdout "") (stderr ""))
  Error:
  "Unix.Unix_error(Unix.ENOENT, \"chdir\", \"$TESTCASE_ROOT/foo\")"
  [123]

Testing an unsuccessful file show with git and via vcs.

  $ git rm hello
  rm 'hello'

  $ git commit -q -m "Removed hello"
  $ rev2=$(git rev-parse HEAD)

  $ volgo-vcs show-file-at-rev hello -r $rev2 2>&1 | sed -e "s/$rev2/rev2/g"
  Path 'hello' does not exist in 'rev2'.

Name status.

  $ volgo-vcs name-status $rev0 $rev2
  ((Added dir/hello) (Removed hello))

Num status.

  $ volgo-vcs num-status $rev0 $rev2
  (((key (One_file dir/hello))
    (num_stat (Num_lines_in_diff (insertions 1) (deletions 0))))
   ((key (One_file hello))
    (num_stat (Num_lines_in_diff (insertions 0) (deletions 1)))))

Stabilize output.

  $ stabilize_output() {
  >   sed -e "s/$rev0/\$REV0/g" -e "s/$rev1/\$REV1/g" -e "s/$rev2/\$REV2/g"
  > }

Refs.

  $ volgo-vcs refs | stabilize_output
  (((rev $REV2)
    (ref_kind (Local_branch (branch_name main)))))

Testing different output formats.

  $ volgo-vcs refs -o dyn | stabilize_output
  [ { rev = "$REV2"
    ; ref_kind = Local_branch { branch_name = "main" }
    }
  ]

  $ volgo-vcs refs -o sexp | stabilize_output
  (((rev $REV2)
    (ref_kind (Local_branch (branch_name main)))))

  $ volgo-vcs refs -o json | stabilize_output
  [
    {
      "rev": "$REV2",
      "ref_kind": { "type": "Local_branch", "branch_name": "main" }
    }
  ]

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
  Error: Rev [2e9ab12edfe8e3a01cf2fa2b46210c042e9ab12e] not found.
  [123]

Descendance.

  $ volgo-vcs descendance $rev1 $rev1
  Same_node

  $ volgo-vcs descendance $rev1 $rev2
  Strict_ancestor

  $ volgo-vcs descendance $rev2 $rev1
  Strict_descendant

  $ volgo-vcs descendance $rev1 2e9ab12edfe8e3a01cf2fa2b46210c042e9ab12e
  Error: Rev [2e9ab12edfe8e3a01cf2fa2b46210c042e9ab12e] not found.
  [123]

Vcs allows to run the git command line directly if the backend supports it.

  $ volgo-vcs git rev-parse HEAD | stabilize_output
  $REV2

  $ volgo-vcs git invalid-command 2> /dev/null
  [1]

When running in a repository of a certain kind, some operations may not be
supported. Below we attempt to run an Mercurial command in this Git repository.

  $ volgo-vcs hg id
  Context:
  (Vcs.hg
   (repo_root
    $TESTCASE_ROOT)
   (args id))
  Error: Trait [Vcs.Trait.hg] method [hg] is not available in this repository.
  [123]

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
