(*******************************************************************************)
(*  Volgo - a Versatile OCaml Library for Git Operations                       *)
(*  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
(*                                                                             *)
(*  This file is part of Volgo.                                                *)
(*                                                                             *)
(*  Volgo is free software; you can redistribute it and/or modify it under     *)
(*  the terms of the GNU Lesser General Public License as published by the     *)
(*  Free Software Foundation either version 3 of the License, or any later     *)
(*  version, with the LGPL-3.0 Linking Exception.                              *)
(*                                                                             *)
(*  Volgo is distributed in the hope that it will be useful, but WITHOUT ANY   *)
(*  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*  the file `NOTICE.md` at the root of this repository for more details.      *)
(*                                                                             *)
(*  You should have received a copy of the GNU Lesser General Public License   *)
(*  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*******************************************************************************)

let%expect_test "vcs-kind-hash" =
  Hash_test.run
    (module Vcs.Platform_repo.Vcs_kind)
    (module Volgo_base.Vcs.Platform_repo.Vcs_kind)
    Vcs.Platform_repo.Vcs_kind.all;
  [%expect
    {|
    ({ value = Git },
     { stdlib_hash = 129913994
     ; vcs_hash = 129913994
     ; vcs_base_hash = 1058613066
     })
    ({ value = Git; seed = 0 },
     { stdlib_hash = 129913994
     ; vcs_hash = 129913994
     ; vcs_base_hash = 1058613066
     })
    ({ value = Git; seed = 42 },
     { stdlib_hash = 269061838; vcs_hash = 269061838; vcs_base_hash = 992140660 })
    ({ value = Hg },
     { stdlib_hash = 883721435; vcs_hash = 883721435; vcs_base_hash = 129913994 })
    ({ value = Hg; seed = 0 },
     { stdlib_hash = 883721435; vcs_hash = 883721435; vcs_base_hash = 129913994 })
    ({ value = Hg; seed = 42 },
     { stdlib_hash = 166027884; vcs_hash = 166027884; vcs_base_hash = 269061838 })
    |}];
  ()
;;

let%expect_test "protocol-hash" =
  Hash_test.run
    (module Vcs.Platform_repo.Protocol)
    (module Volgo_base.Vcs.Platform_repo.Protocol)
    Vcs.Platform_repo.Protocol.all;
  [%expect
    {|
    ({ value = Ssh },
     { stdlib_hash = 129913994
     ; vcs_hash = 129913994
     ; vcs_base_hash = 1058613066
     })
    ({ value = Ssh; seed = 0 },
     { stdlib_hash = 129913994
     ; vcs_hash = 129913994
     ; vcs_base_hash = 1058613066
     })
    ({ value = Ssh; seed = 42 },
     { stdlib_hash = 269061838; vcs_hash = 269061838; vcs_base_hash = 992140660 })
    ({ value = Https },
     { stdlib_hash = 883721435; vcs_hash = 883721435; vcs_base_hash = 129913994 })
    ({ value = Https; seed = 0 },
     { stdlib_hash = 883721435; vcs_hash = 883721435; vcs_base_hash = 129913994 })
    ({ value = Https; seed = 42 },
     { stdlib_hash = 166027884; vcs_hash = 166027884; vcs_base_hash = 269061838 })
    |}];
  ()
;;

let values =
  [ { Vcs.Platform_repo.platform = GitHub
    ; vcs_kind = Git
    ; user_handle = Vcs.User_handle.v "jdoe"
    ; repo_name = Vcs.Repo_name.v "vcs"
    }
  ; { Vcs.Platform_repo.platform = Codeberg
    ; vcs_kind = Hg
    ; user_handle = Vcs.User_handle.v "jdoe"
    ; repo_name = Vcs.Repo_name.v "vcs"
    }
  ]
;;

let%expect_test "hash" =
  Hash_test.run (module Vcs.Platform_repo) (module Volgo_base.Vcs.Platform_repo) values;
  [%expect
    {|
    ({ value =
         { platform = GitHub
         ; vcs_kind = Git
         ; user_handle = "jdoe"
         ; repo_name = "vcs"
         }
     },
     { stdlib_hash = 722289376; vcs_hash = 722289376; vcs_base_hash = 31940564 })
    ({ value =
         { platform = GitHub
         ; vcs_kind = Git
         ; user_handle = "jdoe"
         ; repo_name = "vcs"
         }
     ; seed = 0
     },
     { stdlib_hash = 722289376; vcs_hash = 722289376; vcs_base_hash = 31940564 })
    ({ value =
         { platform = GitHub
         ; vcs_kind = Git
         ; user_handle = "jdoe"
         ; repo_name = "vcs"
         }
     ; seed = 42
     },
     { stdlib_hash = 255089139; vcs_hash = 255089139; vcs_base_hash = 46231834 })
    ({ value =
         { platform = Codeberg
         ; vcs_kind = Hg
         ; user_handle = "jdoe"
         ; repo_name = "vcs"
         }
     },
     { stdlib_hash = 1038571115
     ; vcs_hash = 1038571115
     ; vcs_base_hash = 118788037
     })
    ({ value =
         { platform = Codeberg
         ; vcs_kind = Hg
         ; user_handle = "jdoe"
         ; repo_name = "vcs"
         }
     ; seed = 0
     },
     { stdlib_hash = 1038571115
     ; vcs_hash = 1038571115
     ; vcs_base_hash = 118788037
     })
    ({ value =
         { platform = Codeberg
         ; vcs_kind = Hg
         ; user_handle = "jdoe"
         ; repo_name = "vcs"
         }
     ; seed = 42
     },
     { stdlib_hash = 275801981; vcs_hash = 275801981; vcs_base_hash = 818163617 })
    |}];
  ()
;;

let url_values =
  [ { Vcs.Platform_repo.Url.platform = GitHub
    ; vcs_kind = Git
    ; user_handle = Vcs.User_handle.v "jdoe"
    ; repo_name = Vcs.Repo_name.v "vcs"
    ; protocol = Https
    }
  ; { Vcs.Platform_repo.Url.platform = GitHub
    ; vcs_kind = Git
    ; user_handle = Vcs.User_handle.v "jdoe"
    ; repo_name = Vcs.Repo_name.v "vcs"
    ; protocol = Ssh
    }
  ; { Vcs.Platform_repo.Url.platform = Codeberg
    ; vcs_kind = Hg
    ; user_handle = Vcs.User_handle.v "jdoe"
    ; repo_name = Vcs.Repo_name.v "vcs"
    ; protocol = Https
    }
  ; { Vcs.Platform_repo.Url.platform = Codeberg
    ; vcs_kind = Hg
    ; user_handle = Vcs.User_handle.v "jdoe"
    ; repo_name = Vcs.Repo_name.v "vcs"
    ; protocol = Ssh
    }
  ]
;;

let%expect_test "hash" =
  Hash_test.run
    (module Vcs.Platform_repo.Url)
    (module Volgo_base.Vcs.Platform_repo.Url)
    url_values;
  [%expect
    {|
    ({ value =
         { platform = GitHub
         ; vcs_kind = Git
         ; user_handle = "jdoe"
         ; repo_name = "vcs"
         ; protocol = Https
         }
     },
     { stdlib_hash = 710011599; vcs_hash = 710011599; vcs_base_hash = 329544140 })
    ({ value =
         { platform = GitHub
         ; vcs_kind = Git
         ; user_handle = "jdoe"
         ; repo_name = "vcs"
         ; protocol = Https
         }
     ; seed = 0
     },
     { stdlib_hash = 710011599; vcs_hash = 710011599; vcs_base_hash = 329544140 })
    ({ value =
         { platform = GitHub
         ; vcs_kind = Git
         ; user_handle = "jdoe"
         ; repo_name = "vcs"
         ; protocol = Https
         }
     ; seed = 42
     },
     { stdlib_hash = 429507035; vcs_hash = 429507035; vcs_base_hash = 923827283 })
    ({ value =
         { platform = GitHub
         ; vcs_kind = Git
         ; user_handle = "jdoe"
         ; repo_name = "vcs"
         ; protocol = Ssh
         }
     },
     { stdlib_hash = 615184651; vcs_hash = 615184651; vcs_base_hash = 252115316 })
    ({ value =
         { platform = GitHub
         ; vcs_kind = Git
         ; user_handle = "jdoe"
         ; repo_name = "vcs"
         ; protocol = Ssh
         }
     ; seed = 0
     },
     { stdlib_hash = 615184651; vcs_hash = 615184651; vcs_base_hash = 252115316 })
    ({ value =
         { platform = GitHub
         ; vcs_kind = Git
         ; user_handle = "jdoe"
         ; repo_name = "vcs"
         ; protocol = Ssh
         }
     ; seed = 42
     },
     { stdlib_hash = 478271362; vcs_hash = 478271362; vcs_base_hash = 717526480 })
    ({ value =
         { platform = Codeberg
         ; vcs_kind = Hg
         ; user_handle = "jdoe"
         ; repo_name = "vcs"
         ; protocol = Https
         }
     },
     { stdlib_hash = 132313437; vcs_hash = 132313437; vcs_base_hash = 864452121 })
    ({ value =
         { platform = Codeberg
         ; vcs_kind = Hg
         ; user_handle = "jdoe"
         ; repo_name = "vcs"
         ; protocol = Https
         }
     ; seed = 0
     },
     { stdlib_hash = 132313437; vcs_hash = 132313437; vcs_base_hash = 864452121 })
    ({ value =
         { platform = Codeberg
         ; vcs_kind = Hg
         ; user_handle = "jdoe"
         ; repo_name = "vcs"
         ; protocol = Https
         }
     ; seed = 42
     },
     { stdlib_hash = 674853689; vcs_hash = 674853689; vcs_base_hash = 512522645 })
    ({ value =
         { platform = Codeberg
         ; vcs_kind = Hg
         ; user_handle = "jdoe"
         ; repo_name = "vcs"
         ; protocol = Ssh
         }
     },
     { stdlib_hash = 706171373; vcs_hash = 706171373; vcs_base_hash = 319303260 })
    ({ value =
         { platform = Codeberg
         ; vcs_kind = Hg
         ; user_handle = "jdoe"
         ; repo_name = "vcs"
         ; protocol = Ssh
         }
     ; seed = 0
     },
     { stdlib_hash = 706171373; vcs_hash = 706171373; vcs_base_hash = 319303260 })
    ({ value =
         { platform = Codeberg
         ; vcs_kind = Hg
         ; user_handle = "jdoe"
         ; repo_name = "vcs"
         ; protocol = Ssh
         }
     ; seed = 42
     },
     { stdlib_hash = 543520998; vcs_hash = 543520998; vcs_base_hash = 90942002 })
    |}];
  ()
;;
