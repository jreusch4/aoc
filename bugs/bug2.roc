app "hello"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.6.2/c7T4Hp8bAdWz3r9ZrhboBzibCjJag8d0IP_ljb42yVc.tar.br" }
    imports [pf.Stdout]
    provides [main] to pf


# this should work
expect 1 == 1 # 1 should equal itself.



# (optionally lots of whitespace)


# this failure also prints the first expect above!
expect 1 == 2



main =
    Stdout.line "hi!"
