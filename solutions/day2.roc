app "hello"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br" }
    imports [pf.Stdout, pf.Task, "../inputs/day2.txt" as input : Str]
    provides [main] to pf


redCubes = 12
greenCubes = 13
blueCubes = 14

main =
    lines = input |> Str.split "\n"
    games = lines |> List.keepOks parseGame
    
    _ <- Stdout.line "Part 1: \(part1 games |> Num.toStr)" |> Task.await
    _ <- Stdout.line "Part 2: \(part2 games |> Num.toStr)" |> Task.await
    
    Task.ok {}


part1 = \games ->
    games
        |> List.keepIf isGamePossible
        |> List.map .id
        |> List.sum


part2 = \games ->
    games
        |> List.map (\game -> game.draws |> List.walk emptyDraw maxDraws)
        |> List.map drawPower
        |> List.sum


isGamePossible = \game ->
    draw <- game.draws |> List.all
    draw.reds <= redCubes && draw.greens <= greenCubes && draw.blues <= blueCubes


parseGame = \line ->
    { before: gameIdPrefix, after: drawsStr } <- line |> Str.splitFirst ":" |> Result.try
    { after: idStr } <- gameIdPrefix |> Str.splitLast " " |> Result.try
    id <- Str.toNat idStr |> Result.try

    draws = drawsStr |> Str.split ";" |> List.keepOks parseDraw

    if List.isEmpty draws then
        Err EmptyDraws

    else
        Ok { id, draws }
    

parseDraw = \str ->
    fields = str
        |> Str.split ","
        |> List.map Str.trim
        |> List.keepOks parseField

    if List.isEmpty fields then
        Err EmptyDraw

    else
        draw = fields |> List.walk emptyDraw sumDraws
        Ok draw


parseField = \str ->
    { before: countStr, after: colorStr } <- str |> Str.splitFirst " " |> Result.try
    count <- Str.toNat countStr |> Result.try
    when colorStr is
        "red" -> Ok { emptyDraw & reds: count }
        "green" -> Ok { emptyDraw & greens: count }
        "blue" -> Ok { emptyDraw & blues: count }
        _ -> Err (InvalidColor colorStr)
        

emptyDraw = { reds: 0, greens: 0, blues: 0 }

sumDraws = \draw1, draw2 ->
    { reds: draw1.reds + draw2.reds
    , greens: draw1.greens + draw2.greens
    , blues: draw1.blues + draw2.blues
    }

maxDraws = \draw1, draw2 ->
    { reds: Num.max draw1.reds draw2.reds
    , greens: Num.max draw1.greens draw2.greens
    , blues: Num.max draw1.blues draw2.blues
    }

drawPower = \{ reds, greens, blues } ->
    reds * greens * blues
