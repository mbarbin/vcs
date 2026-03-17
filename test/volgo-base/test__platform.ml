(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "hash" =
  Hash_test.run (module Vcs.Platform) (module Volgo_base.Vcs.Platform) Vcs.Platform.all;
  [%expect
    {|
    ({ value = Bitbucket },
     { stdlib_hash = 129913994
     ; vcs_hash = 129913994
     ; vcs_base_hash = 1058613066
     })
    ({ value = Bitbucket; seed = 0 },
     { stdlib_hash = 129913994
     ; vcs_hash = 129913994
     ; vcs_base_hash = 1058613066
     })
    ({ value = Bitbucket; seed = 42 },
     { stdlib_hash = 269061838; vcs_hash = 269061838; vcs_base_hash = 992140660 })
    ({ value = Codeberg },
     { stdlib_hash = 883721435; vcs_hash = 883721435; vcs_base_hash = 129913994 })
    ({ value = Codeberg; seed = 0 },
     { stdlib_hash = 883721435; vcs_hash = 883721435; vcs_base_hash = 129913994 })
    ({ value = Codeberg; seed = 42 },
     { stdlib_hash = 166027884; vcs_hash = 166027884; vcs_base_hash = 269061838 })
    ({ value = GitHub },
     { stdlib_hash = 648017920; vcs_hash = 648017920; vcs_base_hash = 462777137 })
    ({ value = GitHub; seed = 0 },
     { stdlib_hash = 648017920; vcs_hash = 648017920; vcs_base_hash = 462777137 })
    ({ value = GitHub; seed = 42 },
     { stdlib_hash = 1013383106
     ; vcs_hash = 1013383106
     ; vcs_base_hash = 1005547790
     })
    ({ value = GitLab },
     { stdlib_hash = 152507349; vcs_hash = 152507349; vcs_base_hash = 883721435 })
    ({ value = GitLab; seed = 0 },
     { stdlib_hash = 152507349; vcs_hash = 152507349; vcs_base_hash = 883721435 })
    ({ value = GitLab; seed = 42 },
     { stdlib_hash = 97476682; vcs_hash = 97476682; vcs_base_hash = 166027884 })
    ({ value = Sourcehut },
     { stdlib_hash = 127382775; vcs_hash = 127382775; vcs_base_hash = 607293368 })
    ({ value = Sourcehut; seed = 0 },
     { stdlib_hash = 127382775; vcs_hash = 127382775; vcs_base_hash = 607293368 })
    ({ value = Sourcehut; seed = 42 },
     { stdlib_hash = 688167720
     ; vcs_hash = 688167720
     ; vcs_base_hash = 1062720725
     })
    |}];
  ()
;;
