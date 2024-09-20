# The Power of Traits in `Vcs`

The `Vcs` library leverages the `provider`-based parametric model to offer a flexible and adaptable interface for Git operations. This model, also used in the `Eio` library (`Eio.Resource`), allows us to define small scopes of functionality, or `Traits`, within the `Vcs` library.

## Experience with `providers`

Our use of the [provider](https://github.com/mbarbin/provider) based parametric library in `Vcs` serves as a practical, real-world case study of this pattern.

We aim to bring this pattern to the attention of the community, fostering a general understanding that can be applied to other projects using the same pattern. In essence, understanding the parametrized model of `Vcs` equates to understanding `Eio.Resource`, and vice versa.

## Granularity of the Interface via Trait Granularity

The `Trait` design of `provider` allows us to define specific and isolated sub-functionalities within the `Vcs` library. This granularity enables different providers to choose which `Trait` they wish to implement, offering a level of flexibility not possible with a monolithic functor.

With `Traits`, you can select a provider with the specific set of traits you need, without changing any other code. As explained [here](https://mbarbin.github.io/provider/provider/Provider/Interface/index.html#type-t), provider interfaces come with some notion of phantom types, offering additional compiler assistance.

In summary, the use of `Traits` in `Vcs` provides a flexible, adaptable, and granular interface for Git operations, promoting a broader understanding and application of the `provider`-based parametric model.
