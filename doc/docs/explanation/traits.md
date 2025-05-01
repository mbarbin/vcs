# The Power of Traits in `Vcs`

The `Vcs` library leverages OCaml Objects to offer a flexible and adaptable interface for Git operations. This model allows us to define small scopes of functionality, or `Traits`, within the `Vcs` library.

## Experience with `providers`

We conducted an early experiment using the [provider](https://github.com/mbarbin/provider) library for a practical, real-world case study of this pattern.

We aimed to bring this pattern to the attention of the community, fostering a general understanding that can be applied to other projects using the same pattern. In essence, understanding the parametrized model of `Vcs` equates to understanding `Eio.Resource`, and vice versa.

However, after an initial experiment, we ended up switching from using Provider to resorting to OCaml Objects directly.

## Granularity of the Interface via Trait Granularity

The `Trait` design of `vcs` allows us to define specific and isolated sub-functionalities within the library. This granularity enables different providers to choose which `Trait` they wish to implement, offering a level of flexibility not possible with a monolithic functor.

With `Traits`, you can select a backend with the specific set of traits you need, without changing any other code. In user code, you can specify the exact list of traits you require, while keeping the type open so your code is compatible with any backend providing *at least* the traits you need.

In summary, the use of `Traits` in `Vcs` provides a flexible, adaptable, and granular interface for Git operations, promoting a broader understanding and application of a parametric model based on row-polymorphism.
