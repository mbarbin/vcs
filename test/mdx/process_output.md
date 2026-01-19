# Process output

This test monitors that the types to manipulate the output of the `git` and `hg` processes are not unifiable, for the purpose of added type safety.

```ocaml
let process_git_output (_ : Vcs.Git.Output.t) = ()

let () =
  let hg_output = { Vcs.Hg.Output.exit_code = 0; stdout = ""; stderr = "" } in
  process_git_output hg_output
```
```mdx-error
Line 5, characters 24-33:
Error: The value hg_output has type Vcs.Hg.Output.t
       but an expression was expected of type Vcs.Git.Output.t
```
