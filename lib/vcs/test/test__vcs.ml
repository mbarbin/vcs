let%expect_test "hello" =
  print_s Vcs.hello_world;
  [%expect {| "Hello, World!" |}]
;;
