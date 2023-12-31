app "hello"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.6.2/c7T4Hp8bAdWz3r9ZrhboBzibCjJag8d0IP_ljb42yVc.tar.br" }
    imports [pf.Stdout]
    provides [main] to pf

prefixes = \str, soFar ->
    if Str.isEmpty str then
        soFar

    else
        next = str
            |> Str.graphemes
            |> List.dropFirst 1
            |> Str.joinWith ""

        prefixes next (List.append soFar str)

expect prefixes "abc" [] == ["abc", "c", ""] # passes
expect prefixes "abc" [] == ["abc", "bc", "c"] # fails

main =
    dbg prefixes "abc" []
    Stdout.line "hi"

