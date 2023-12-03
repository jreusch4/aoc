app "hello"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br" }
    imports [pf.Stdout, pf.Task, "../inputs/day3.txt" as input : Str]
    provides [main] to pf


main =
    _ <- Stdout.line "Part 1: \(Num.toStr part1)" |> Task.await
    _ <- Stdout.line "Part 2: \(Num.toStr part2)" |> Task.await
    Task.ok {}


chars = input |> Str.trim |> Str.split "\n" |> List.map Str.toUtf8
parts = chars |> runs2d isDigit


part1 =
    symbols = chars |> runs2d isSymbol

    validParts =
        part <- parts |> List.keepIf
        symbol <- symbols |> List.any
        surr <- surrounding symbol |> List.any
        intersects surr part

    partNumbers = validParts |> List.keepOks partNumber

    List.sum partNumbers


part2 = 
    gearRatios =
        gear <- chars |> runs2d isGear |> List.keepOks
        surr = surrounding gear

        adjacentParts =
            part <- parts |> List.keepIf
            s <- surr |> List.any
            intersects s part

        when adjacentParts is
            [run1, run2] ->
                partNumber1 <- partNumber run1 |> Result.try
                partNumber2 <- partNumber run2 |> Result.try
                Ok (partNumber1 * partNumber2)

            _ ->
                Err NotAGear
            
    List.sum gearRatios
    

isDigit = \chr ->
    chr >= '0' && chr <= '9'

isSymbol = \chr ->
    isDigit chr == Bool.false && chr != '.'

isGear = \chr ->
    chr == '*'


Run : { line: I32, start: I32, end: I32 }


partNumber = \part ->
    line <- chars |> List.get (Num.toNat part.line) |> Result.try
    str <- line
        |> Str.fromUtf8Range
            { start: Num.toNat part.start
            , count: Num.toNat (part.end - part.start + 1)
            } 
        |> Result.try
    Str.toNat str


surrounding : Run -> List Run
surrounding = \{ line, start, end } ->
    top = { line: line - 1, start: start - 1, end: end + 1 }
    bottom = { line: line + 1, start: start - 1, end: end + 1 }
    left = { line, start: start - 1, end: start - 1}
    right = { line, start: end + 1, end: end + 1 }
    [top, bottom, left, right]


intersects : Run, Run -> Bool
intersects = \run1, run2 ->
    run1.line == run2.line && run1.end >= run2.start && run2.end >= run1.start


runs2d : List (List a), (a -> Bool) -> List Run
runs2d = \list, pred ->
    acc, inner, line <- list |> List.walkWithIndex []
    acc2, (start, end) <- inner |> runs pred |> List.walk acc
    List.append acc2 { start: Num.toI32 start, end: Num.toI32 end, line: Num.toI32 line }


runs : List a, (a -> Bool) -> List (Nat, Nat)
runs = \list, pred ->
    runHelp pred list (Err Nothing) 0 []


runHelp = \pred, list, maybeStart, curr, acc ->
    when list is
        [] ->
            when maybeStart is
                Ok start ->
                    List.append acc (start, curr - 1)

                Err Nothing ->
                    acc

        [head, .. as tail] ->
            if pred head then
                start = maybeStart |> Result.onErr (\_ -> Ok curr)
                runHelp pred tail start (curr + 1) acc

            else
                when maybeStart is
                    Ok start -> 
                        runHelp pred tail (Err Nothing) (curr + 1) (List.append acc (start, curr - 1))

                    Err Nothing ->
                        runHelp pred tail (Err Nothing) (curr + 1) acc
    

