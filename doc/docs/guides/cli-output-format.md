# CLI Output Format

## Summary

Version `0.0.22` introduces a new `--output-format` (or `-o`) option to the `volgo-vcs` CLI, allowing you to choose between `sexp`, `json`, and `dyn` output formats.

## Stability Notice

The `volgo-vcs` CLI is designed for exploratory testing and debugging of the Volgo libraries. **Using it in production scripts is outside the intended scope and will result in almost guaranteed problems.** Its output format and behavior may change between releases without stability guarantees.

If you use `volgo-vcs` in test suites where you control the upgrade cycle and can accommodate breaking changes, specifying `-o` explicitly will help reduce churn when defaults change.

## Available Formats

You can choose the output format using `-o` (or `--output-format`):

```sh
$ volgo-vcs refs -o sexp
(((rev e4f8b2a1c3d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9)
  (ref_kind (Local_branch (branch_name main)))))

$ volgo-vcs refs -o json
[
  {
    "rev": "e4f8b2a1c3d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9",
    "ref_kind": { "type": "Local_branch", "branch_name": "main" }
  }
]

$ volgo-vcs refs -o dyn
[ { rev = "e4f8b2a1c3d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9"
  ; ref_kind = Local_branch { branch_name = "main" }
  }
]
```

| Format | Description |
| ------ | ----------- |
| `sexp` | S-expression format (current default) |
| `json` | JSON format, suitable for parsing with `jq` and other tools |
| `dyn`  | OCaml Dyn format, useful for debugging |
