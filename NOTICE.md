# License

`Volgo` is released under the terms of the `LGPL-3.0-or-later WITH LGPL-3.0-linking-exception` license.

This notice file contains more details, as well as document the organization of files and headers that relate to licenses.

## License, copyright & notices

- **COPYING.HEADER** contains the copyright and license notices. It is added as a header to every file in the project.

- **COPYING** contains a copy of the full [GPL-3.0 license](https://www.gnu.org/licenses/gpl-3.0.txt)

- **COPYING.LESSER** contains a copy the full [LGPL-3.0 license](https://www.gnu.org/licenses/lgpl-3.0.txt)

- **COPYING.LINKING** contains a copy of the [LGPL-3.0-linking-exception](https://spdx.org/licenses/LGPL-3.0-linking-exception.html) notice.

- **NOTICE.md** (this file) documents the project licensing.

## A note about Eio-process

To spawn processes in `Eio` and collect their output we've copied some code from the [Eio_process](https://github.com/mbarbin/eio-process) project. The `Eio_process` project is released under `MIT`.

### Notice

The file where we make use of this code is `src/volgo-git-eio/runtime.ml`. We've added a notice in the file and a comment next to the code that was copied and modified, which includes `Eio_process`'s original LICENSE:

```text
MIT License

Copyright (c) 2023 Mathieu Barbin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## A note about Base.String.split_lines

We copied the implementation of some functions from the [Base](https://github.com/janestreet/base) project. `Base` is released under `MIT`.

### Notice

The file where we imported the functions is `src/stdlib/volgo_stdlib.ml`. We've added a notice in the file and a comment next to the code that was copied and modified, which includes `Base`'s original LICENSE:

```text
The MIT License

Copyright (c) 2016--2024 Jane Street Group, LLC <opensource-contacts@janestreet.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

The license of base is also included [here](third-party-license/janestreet/base/LICENSE.md).

## A note about Iron

In 2016-2017, Jane Street released on GitHub an internal code review system named [Iron](https://github.com/janestreet/iron).

`Iron` includes functionality for interacting with `Mercurial` repositories. `Vcs` is not a code review system, but since it is a library that implements `Git` interaction, it has similarities with that specific `Mercurial` part of `Iron`.

Iron was released under the terms of the [Apache 2.0](http://www.apache.org/licenses/LICENSE-2.0) License.

We've included a copy of the `Apache-2.0` License in the repository [here](./3rd-party-license/LICENSE-apache-2.0.txt)

We're referring to the Iron source code as of `v0.9.114.44+47`, revision `dfb106cb82abf5d16e548d4ee4f419d0994d3644`.

### Derivative work

For a few modules within the `Vcs` library, we've taken some inspiration from `Iron`. As such, these parts of `Vcs` may be regarded as constituting a "Derivative Work" as defined by the `Apache-2.0` License.

Iron targets `Mercurial`, and also the source code has various dependencies (e.g. `core`) which are not `Vcs` dependencies, thus including code from `Iron` directly would probably not compile and not achieve the desired behavior. Thus, we have not copied large portions of code directly. By "inspiration", we mean that we have used the `Iron` code as an external reference, sometimes taking small portions of code, function names or types, and modifying and adapting it for the purpose of `Vcs`.

#### Notices

The files in question carry prominent notices stating that their contents is partially derived from files from the `Iron` project. We include the path of said files relative to the root of the `Iron` project repository, as well as a description of the changes made.

For example, in addition to the vcs project header, such file would carry the following extra header:

```ocaml
(* This module is partially derived from Iron (v0.9.114.44+47), file
 * [./path/to/file], which is released under Apache 2.0:
 *
 * Copyright (c) 2016-2017 Jane Street Group, LLC <opensource-contacts@janestreet.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy
 * of the License at:
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 *
 * See the file `NOTICE.md` at the root of this repository for more details.
 *
 * Changes: ...
 *)
```

The full license of iron is included [here](third-party-license/janestreet/iron/LICENSE).

#### List of modules

The exact list of modules that are partially derived from `Iron` is as follows:

- src/volgo/name_status
- src/volgo/path_in_repo
- src/volgo/repo_root
