First we need to setup a repo in a way that satisfies the test environment. This
includes specifics required by the GitHub Actions environment.

  $ hg init 2> /dev/null

  $ cat > hello << EOF
  > Hello World
  > EOF

  $ cat hello
  Hello World

  $ volgo-vcs add hello
  $ rev0=$(volgo-vcs commit -m "Initial commit")

Rev-parse.

  $ hg log -r . --template "{node}\n" 2> /dev/null | sed -e "s/$rev0/rev0/g"
  rev0

  $ volgo-vcs current-revision | sed -e "s/$rev0/rev0/g"
  rev0

  $ volgo-vcs current-branch
  Context:
  (Vcs.current_branch
   (repo_root
    $TESTCASE_ROOT))
  Error: Branches are not implemented in [vcs-hg].
  [123]

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

  $ volgo-vcs ls-files --below foo 2> /dev/null
  [123]

Vcs allows to run the git command line directly if the backend supports it.

  $ volgo-vcs hg -- log -r . --template "{node}" 2> /dev/null | sed -e "s/$rev1/rev1/g"
  rev1

  $ volgo-vcs hg invalid-command 2> /dev/null
  [255]

When running in a repository of a certain kind, some operations may not be
supported. Below we attempt to run an Mercurial command in this Git repository.

  $ volgo-vcs git not-run
  Context:
  (Vcs.git
   (repo_root
    $TESTCASE_ROOT)
   (args not-run))
  Error: Trait [Vcs.Trait.git] method [git] is not available in this
  repository.
  [123]
