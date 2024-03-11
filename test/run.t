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
  $ ocaml-vcs commit -q -m "Initial commit"

Making sure the branch name is deterministic.

  $ ocaml-vcs rename-current-branch main

Testing a successful file show with git and via vc.

  $ git show HEAD:hello
  Hello World

  $ rev1=$(git rev-parse HEAD)

  $ ocaml-vcs show-file-at-rev hello -r $rev1
  Hello World

  $ mkdir -p untracked
  $ echo "New untracked file" > untracked/hello

  $ ocaml-vcs load-file untracked/hello
  New untracked file

Adding a new file under a directory

  $ mkdir dir
  $ echo "New file" > dir/hello

  $ ocaml-vcs add dir/hello
  $ ocaml-vcs commit -q -m "Added dir/hello"

  $ ocaml-vcs ls-files
  dir/hello
  hello
  $ ocaml-vcs ls-files --below dir
  dir/hello

Testing an unsuccessful file show with git and via vc.

  $ git rm hello
  rm 'hello'

  $ git commit -q -m "Removed hello"
  $ rev2=$(git rev-parse HEAD)

  $ ocaml-vcs show-file-at-rev hello -r $rev2 2>&1 | sed -e "s/$rev2/rev2/g"
  Path 'hello' does not exist in 'rev2'

Name status

  $ ocaml-vcs name-status $rev1 $rev2
  ((Added dir/hello) (Removed hello))

Num status

  $ ocaml-vcs num-status $rev1 $rev2
  (((key (One_file dir/hello))
    (num_lines_in_diff ((insertions 1) (deletions 0))))
   ((key (One_file hello)) (num_lines_in_diff ((insertions 0) (deletions 1)))))
