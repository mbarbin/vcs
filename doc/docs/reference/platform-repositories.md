# Platform Repositories

## What are Platform Repositories in `vcs`?

A **platform repository** in `vcs` is a structured, type-safe representation of a repository hosted on a well-known online platform, such as GitHub, GitLab, Sourcehut, Bitbucket, or Codeberg. This abstraction allows you to refer to repositories in a uniform way, regardless of the underlying platform or version control system (VCS) used (e.g., Git or Mercurial).

The platform repository interface is available as a module of the library, named `Vcs.Platform_repo`.

Platform repositories are designed to make it easy to:
- Generate and parse repository URLs for cloning, fetching, or pushing.
- Convert between different URL syntaxes (e.g., SSH scp-like, SSH URI, HTTPS).
- Support platform-specific conventions (such as Sourcehut's `~user` namespace).
- Provide a foundation for higher-level tooling and automation.

## Goals

- **Convenience:** Offer a simple and reliable way to refer to online repositories in code, scripts, and tools.
- **Interoperability:** Support the most common platforms and VCS combinations out of the box.
- **Extensibility:** Make it easy to add support for new platforms, VCSs, or URL styles as the ecosystem evolves.
- **Safety:** Prevent common mistakes by validating user/repo names and URL formats.

## Current Support

The following platforms and VCS combinations are currently supported:

| Platform   | Git | Mercurial (Hg) | Notes                                  |
|------------|-----|----------------|----------------------------------------|
| GitHub     | ✅  | ❌             | Git only                               |
| GitLab     | ✅  | ❌             | Git only                               |
| Codeberg   | ✅  | ❌             | Git only (Gitea-based)                 |
| Bitbucket  | ✅  | ⚠️ (legacy)    | Mercurial support was removed in 2020  |
| Sourcehut  | ✅  | ✅             | Both Git and Mercurial supported       |

### Example URL Forms

### Example URL Forms

| Platform   | VCS        | Protocol      | Example URL                                 |
|------------|------------|---------------|---------------------------------------------|
| GitHub     | Git        | HTTPS         | `https://github.com/user/repo.git`          |
| GitHub     | Git        | SSH (scp)     | `git@github.com:user/repo.git`              |
| GitHub     | Git        | SSH (url)     | `ssh://git@github.com/user/repo.git`        |
| GitLab     | Git        | HTTPS         | `https://gitlab.com/user/repo.git`          |
| GitLab     | Git        | SSH (scp)     | `git@gitlab.com:user/repo.git`              |
| GitLab     | Git        | SSH (url)     | `ssh://git@gitlab.com/user/repo.git`        |
| Codeberg   | Git        | HTTPS         | `https://codeberg.org/user/repo.git`        |
| Codeberg   | Git        | SSH (scp)     | `git@codeberg.org:user/repo.git`            |
| Codeberg   | Git        | SSH (url)     | `ssh://git@codeberg.org/user/repo.git`      |
| Bitbucket  | Git        | HTTPS         | `https://bitbucket.org/user/repo.git`       |
| Bitbucket  | Git        | SSH (scp)     | `git@bitbucket.org:user/repo.git`           |
| Bitbucket  | Git        | SSH (url)     | `ssh://git@bitbucket.org/user/repo.git`     |
| Bitbucket  | Mercurial  | HTTPS         | `https://bitbucket.org/user/repo`           |
| Bitbucket  | Mercurial  | SSH (scp)     | `hg@bitbucket.org/user/repo`                |
| Bitbucket  | Mercurial  | SSH (url)     | `ssh://hg@bitbucket.org/user/repo`          |
| Sourcehut  | Git        | HTTPS         | `https://git.sr.ht/~user/repo.git`          |
| Sourcehut  | Git        | SSH (scp)     | `git@git.sr.ht:~user/repo.git`              |
| Sourcehut  | Git        | SSH (url)     | `ssh://git@git.sr.ht/~user/repo.git`        |
| Sourcehut  | Mercurial  | HTTPS         | `https://hg.sr.ht/~user/repo`               |
| Sourcehut  | Mercurial  | SSH (scp)     | `hg@hg.sr.ht:~user/repo`                    |
| Sourcehut  | Mercurial  | SSH (url)     | `ssh://hg@hg.sr.ht/~user/repo`              |

> **Note:**
> - For Mercurial, URLs do **not** include a `.hg` suffix.
> - For Git, the `.git` suffix is standard but not always required by all platforms.
> - Sourcehut requires a `~` before the username in the path.

## Limitations

- **Local repositories:**
  Local filesystem paths (e.g., `/home/user/repo.git` or `file:///...`) are **not** targeted by the platform repository abstraction (`Platform_repo`). The focus of this module is on online, hosted repositories.
- **Nested groups/subgroups:**
  URLs with nested organizations or subgroups (e.g., `org/subgroup/repo`) are not yet fully supported or tested.
- **Custom SSH usernames/ports:**
  Only the default SSH usernames (`git` or `hg`) and standard ports are supported.
- **Bitbucket Mercurial:**
  Mercurial support on Bitbucket is only relevant for legacy/self-hosted instances, as Bitbucket Cloud removed Hg support in 2020.
- **Ambiguity in parsing:**
  Some URLs (especially Bitbucket HTTPS) do not distinguish between Git and Hg in the URL itself; the library defaults to Git in ambiguous cases.

## Extensibility and Contributions

This abstraction is meant primarily as a **convenient means to refer to online repositories**. We welcome feedback, discussions, and contributions to extend support for more platforms, VCSs, or URL forms.

If you have a use case that is not covered, or want to propose improvements, please [open an issue or pull request](https://github.com/mbarbin/vcs) on the project GitHub!

---

*Last updated: June 2025*
