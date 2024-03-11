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

  $ git rev-parse main | sed -e "s/$rev0/rev0/g"
  rev0

  $ ocaml-vcs rev-parse | sed -e "s/$rev0/rev0/g"
  rev0

  $ ocaml-vcs rev-parse main | sed -e "s/$rev0/rev0/g"
  rev0

Testing a successful file show with git and via vcs.

  $ git show HEAD:hello
  Hello World

  $ ocaml-vcs show-file-at-rev hello -r $rev0
  Hello World

Save / Load files.

  $ mkdir -p untracked
  $ echo "New untracked file" | ocaml-vcs save-file untracked/hello

  $ ocaml-vcs load-file untracked/hello
  New untracked file

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
    (num_lines_in_diff ((insertions 1) (deletions 0))))
   ((key (One_file hello)) (num_lines_in_diff ((insertions 0) (deletions 1)))))

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
   (Init (rev $REV0)))

Tree.

  $ ocaml-vcs tree | stabilize_output
  ((refs (($REV2 refs/heads/main)))
   (roots ($REV0))
   (tips (($REV2 (refs/heads/main)))))
