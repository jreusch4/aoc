app "hello"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br" }
    imports [pf.Stdout, pf.Task, "../inputs/day4.txt" as input : Str]
    provides [main] to pf

example =
"""
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
""" |> Str.trim

main =
    cards = input |> Str.trim |> Str.split "\n" |> List.keepOks parseCard
    dbg List.len cards

    points = cards |> List.map getPoints |> List.sum
    _ <- Stdout.line "Part 1: \(Num.toStr points)" |> Task.await
    
    Task.ok {}


getPoints = \{ winningNumbers, cardNumbers } ->
    numberOfWinners = Set.intersection winningNumbers cardNumbers |> Set.len
    
    if numberOfWinners > 0 then
        Num.powInt 2 (numberOfWinners - 1)

    else
        0
    

parseCard = \line ->
    { before: cardIdStr, after: numbersStr } <- line |> Str.splitFirst ": " |> Result.try
    { after: idStr } <- cardIdStr |> Str.splitFirst " " |> Result.try
    id <- idStr |> Str.trim |> Str.toNat |> Result.tr

    { before: winningNumbersStr, after: cardNumbersStr } <- numbersStr |> Str.splitFirst " | " |> Result.try

    winningNumbers = parseNumbers winningNumbersStr
    cardNumbers = parseNumbers cardNumbersStr

    Ok { id, winningNumbers, cardNumbers }


parseNumbers = \str ->
    str
        |> Str.split " "
        |> List.keepOks Str.toNat
        |> Set.fromList
