app "hello"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.6.2/c7T4Hp8bAdWz3r9ZrhboBzibCjJag8d0IP_ljb42yVc.tar.br" }
    imports [pf.Stdout, pf.Task, "../inputs/day1.txt" as input : Str]
    provides [main] to pf

main =
    numbers = input
        |> Str.split "\n"
        |> List.map parseNumbersPart2
    
    calibrations =
        lineNumbers <- List.keepOks numbers
        first <- List.first lineNumbers |> Result.try
        last <- List.last lineNumbers |> Result.try

        Ok (first * 10 + last)

    sum = List.sum calibrations
    
    Stdout.line "Sum of calibration numbers: \(Num.toStr sum)"


numberNames = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
numberDigits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

getInits = \line ->
    chars = Str.graphemes line
    soFar, idx <- List.walk (List.range { start: At 0, end: Length (List.len chars) }) []
    List.append soFar (chars |> List.dropFirst idx |> Str.joinWith "")

parseNumbersPart1 = \line ->
    init <- getInits line |> List.keepOks
    findPrefix numberDigits init

parseNumbersPart2 = \line ->
    init <- getInits line |> List.keepOks
    _ <- findPrefix numberNames init |> Result.onErr
    findPrefix numberDigits init

findPrefix = \prefixes, line ->
    prefix <- List.findFirstIndex prefixes
    Str.startsWith line prefix


