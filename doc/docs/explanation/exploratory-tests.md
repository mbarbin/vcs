# Exploratory tests

The `volgo-vcs` opam package introduces an executable, `volgo-vcs`, designed to bring the core functionalities of the *volgo* packages directly to your command line.

It's a practical tool for conducting exploratory testing within your repositories, and reproducing bugs or issues externally, for a smoother debugging process. As a live code sample, it also demonstrates the use of the library.

Whether you're testing new features, diagnosing problems, or seeking to understand the library's application, `volgo-vcs` can be a useful resource.

:::warning[Not intended for stable scripts]

The `volgo-vcs` CLI is designed primarily for **exploratory testing and debugging** purposes. It is **not intended** to be consumed by stable scripts or automated pipelines.

**Output format instability**: The precise structure and formatting of the CLI output (including `--output-format` options like `Dyn`, `Json`, and `Sexp`) are subject to change over time without stability guarantees. We may modify, extend, or restructure the output in future releases without prior notice.

**Development standards**: This CLI component is generally developed with slightly less rigorous stability standards compared to the user-facing library APIs (such as `Vcs`, `Volgo`, etc.). While the code is thoroughly tested and functional, it remains somewhat experimental. You may encounter rough edges or behaviors that differ from your expectations.

**We welcome your feedback!** If you encounter issues, unexpected behaviors, or have suggestions for improvements, please don't hesitate to [open an issue](https://github.com/mbarbin/vcs/issues) on GitHub. Your bug reports and feedback help us improve this tool.
