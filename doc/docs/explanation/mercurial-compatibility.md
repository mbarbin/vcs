# Mercurial Compatibility

Vcs is fundamentally a Git-centric library, but it also provides a *compatibility mode* for Mercurial repositories. This mode is intended to allow you to perform certain Git operations in a Mercurial repository, as long as there is a clear and meaningful mapping between the two systems for the operation in question.

## Introduction

The Mercurial compatibility in vcs is not a full Mercurial backend based on a generic VCS abstraction. Instead, it is a pragmatic approach: if a Git operation (represented as a "Trait" in volgo's terminology) can be mapped to an equivalent or similar operation in Mercurial, then that operation may be supported in the Mercurial backend.

All types, names, and semantics in Vcs remain Git-centric. For example, concepts like branches, commits, and diffs are interpreted as they are in Git. The Mercurial backend attempts to provide compatible behavior where possible, but does not attempt to fully generalize or abstract over the differences between Git and Mercurial.

## Guidelines for Adding Mercurial Support for Traits

When considering whether to add support for a Trait in the Mercurial backend, keep the following guidelines in mind:

- **Type Compatibility:** Only add support if the types and semantics of the Trait can be mapped to Mercurial in a way that feels natural and consistent with Git's behavior.
- **Behavioral Mapping:** The mapping should be as close as possible to the Git operation, both in terms of behavior and user expectations.
- **Not Full Parametrization:** This is not intended to be a complete, fully-parametric VCS abstraction. Only implement what makes sense and is maintainable.
- **Project-Specific Decisions:** Some mappings may be opinionated or project-specific. For example, mapping Git branches to Mercurial branches vs. bookmarks is a nuanced decision, and Vcs may choose the mapping that best fits its goals, even if it is not the only possible approach.
- **Document Limitations:** If a mapping is partial or has caveats, document these clearly in the code and user documentation.

## Examples

- **Revisions:** Both Git and Mercurial use 40-character hexadecimal strings to identify revisions (commit hashes in Git, changeset hashes in Mercurial). Vcs uses these 40-character revision identifiers in both systems, providing a unified way to refer to revisions regardless of the underlying VCS.
- **Branches:** In Git, branches are references to commits. In Mercurial, both named branches and bookmarks exist, and either could be used to represent Git branches. The choice made in Vcs should be documented.
- **Commits:** Both systems have the concept of commits, but metadata and behavior may differ. Only expose what can be mapped cleanly.
- **Diffs:** Computing diffs between revisions is generally possible in both systems, but edge cases may exist.

## Limitations

- Not all Git operations will have a meaningful or safe mapping to Mercurial.
- The compatibility mode is not intended to be exhaustive or to cover all use cases.
- Some operations may be intentionally unsupported to avoid confusion or semantic mismatches.

## Conclusion

The goal of Mercurial compatibility mode is to provide practical interoperability for common workflows, not to erase the differences between Git and Mercurial. Where a close mapping exists, Vcs aims to support it; where it does not, the operation will remain unsupported.

If you have suggestions for additional mappings or improvements, please open an issue or discussion on GitHub!
