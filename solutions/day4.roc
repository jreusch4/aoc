app "hello"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br" }
    imports [pf.Stdout, pf.Task, "../inputs/day4.txt" as input : Str]
    provides [main] to pf

main =
    cards = input |> Str.trim |> Str.split "\n" |> List.keepOks parseCard

    part1 =
        acc, card <- cards |> List.walk 0
        exponent = numberOfWins card
        if exponent > 0 then
            acc + Num.powInt 2 (exponent - 1)

        else
            acc

    part2 =
        process = \stack, initialTally, initialCache ->
            (tally, cache), card <- stack |> List.walk (initialTally, initialCache)
            when Dict.get cache card.id is
                Ok subTally ->
                    (tally + subTally + 1, cache)

                Err KeyNotFound ->
                    (subTally, newCache) =
                        cards
                            |> List.sublist { start: card.id, len: numberOfWins card }
                            |> process 0 cache

                    (tally + subTally + 1, Dict.insert newCache card.id subTally)
        
        cards |> process 0 (Dict.empty {}) |> .0

    _ <- Stdout.line "Part 1: \(Num.toStr part1)" |> Task.await
    _ <- Stdout.line "Part 2: \(Num.toStr part2)" |> Task.await
    
    Task.ok {}


numberOfWins = \{ winningNumbers, cardNumbers } ->
    Set.intersection winningNumbers cardNumbers |> Set.len


parseCard = \line ->
    { before: cardIdStr, after: numbersStr } <- line |> Str.splitFirst ": " |> Result.try
    { after: idStr } <- cardIdStr |> Str.splitFirst " " |> Result.try
    id <- idStr |> Str.trim |> Str.toNat |> Result.try

    { before: winningNumbersStr, after: cardNumbersStr } <- numbersStr |> Str.splitFirst " | " |> Result.try

    winningNumbers = parseNumbers winningNumbersStr
    cardNumbers = parseNumbers cardNumbersStr

    Ok { id, winningNumbers, cardNumbers }


parseNumbers = \str ->
    str
        |> Str.split " "
        |> List.keepOks Str.toNat
        |> Set.fromList
