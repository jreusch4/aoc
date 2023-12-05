app "hello"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br" }
    imports [pf.Stdout, pf.Task, "../inputs/day5.txt" as input : Str]
    provides [main] to pf

example =
"""
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
"""

main =
    solve = \almanac ->
        minLocation, { start, len } <- almanac.seeds |> List.walk (Num.toNat Num.maxU64)
        minLocation2, seed <- List.range { start: At start, end: Length len } |> List.walk minLocation
        location =
            seed
                |> lookupDest almanac.seedToSoil
                |> lookupDest almanac.soilToFertilizer
                |> lookupDest almanac.fertilizerToWater
                |> lookupDest almanac.waterToLight
                |> lookupDest almanac.lightToTemperature
                |> lookupDest almanac.temperatureToHumidity
                |> lookupDest almanac.humidityToLocation
        Num.min location minLocation2

        
    parseSeedsPart1 = \seedsStr ->    
        seeds <- seedsStr
            |> Str.split " "
            |> List.mapTry Str.toNat
            |> Result.map

        seed <- List.map seeds
        { start: seed, len: 1 }


    part1 = input
        |> parseAlmanac parseSeedsPart1 emptyAlmanac
        |> Result.map solve
        |> unwrap "part 1"

    _ <- Stdout.line "Part 1: \(Num.toStr part1)" |> Task.await


    parseSeedsPart2 = \seedsStr ->
        seeds <- seedsStr
            |> Str.split " "
            |> List.chunksOf 2
            |> List.mapTry

        when seeds is
            [startStr, lenStr] ->
                start <- Str.toNat startStr |> Result.try
                len <- Str.toNat lenStr |> Result.try
                Ok { start, len }

            _ ->
                Err InvalidSeed

    
    part2 = input
        |> parseAlmanac parseSeedsPart2 emptyAlmanac
        |> Result.map solve
        |> unwrap "part 2"
        
    _ <- Stdout.line "Part 2: \(Num.toStr part2)" |> Task.await

    Task.ok {}


unwrap = \result, msg ->
    when result is
        Ok value -> value
        Err err ->
            dbg Unwrap msg err
            crash msg


Map : List MapEntry
MapEntry : { dest: Nat, src: Nat, len: Nat }


Almanac :
    { seeds : List { start: Nat, len: Nat }
    , seedToSoil : Map
    , soilToFertilizer : Map
    , fertilizerToWater : Map
    , waterToLight : Map
    , lightToTemperature : Map
    , temperatureToHumidity : Map
    , humidityToLocation : Map
    }


emptyAlmanac : Almanac
emptyAlmanac =
    { seeds: []
    , seedToSoil: []
    , soilToFertilizer: []
    , fertilizerToWater: []
    , waterToLight: []
    , lightToTemperature: []
    , temperatureToHumidity: []
    , humidityToLocation: []
    }


lookupDest : Nat, Map -> Nat
lookupDest = \src, map ->
    maybeEntry =
        entry <- map |> List.findFirst
        # No short-circuting in Roc?
        # src >= entry.src && (src - entry.src) < entry.len
        if src >= entry.src then
            src - entry.src < entry.len

        else
            Bool.false

    when maybeEntry is
        Ok entry ->
            (src - entry.src) + entry.dest

        Err NotFound ->
            src


###
### PARSING
###


parseAlmanac = \str, parseSeeds, almanac ->
    (line, rest) = chompLine str
    when line is
        "" ->
            if Str.isEmpty rest then
                Ok almanac

            else
                parseAlmanac rest parseSeeds almanac

        _ if Str.startsWith line "seeds: " ->
            { after: seedsStr } <- line |> Str.splitFirst ": " |> Result.try
            seeds <- parseSeeds seedsStr |> Result.try
            parseAlmanac rest parseSeeds { almanac & seeds }

        "seed-to-soil map:" ->
            (seedToSoil, rest2) <- parseMapBody rest almanac.seedToSoil |> Result.try
            parseAlmanac rest2 parseSeeds { almanac & seedToSoil }

        "soil-to-fertilizer map:" ->
            (soilToFertilizer, rest2) <- parseMapBody rest almanac.soilToFertilizer |> Result.try
            parseAlmanac rest2 parseSeeds { almanac & soilToFertilizer }

        "fertilizer-to-water map:" ->
            (fertilizerToWater, rest2) <- parseMapBody rest almanac.fertilizerToWater |> Result.try
            parseAlmanac rest2 parseSeeds { almanac & fertilizerToWater }

        "water-to-light map:" ->
            (waterToLight, rest2) <- parseMapBody rest almanac.waterToLight |> Result.try
            parseAlmanac rest2 parseSeeds { almanac & waterToLight }

        "light-to-temperature map:" ->
            (lightToTemperature, rest2) <- parseMapBody rest almanac.lightToTemperature |> Result.try
            parseAlmanac rest2 parseSeeds { almanac & lightToTemperature }

        "temperature-to-humidity map:" ->
            (temperatureToHumidity, rest2) <- parseMapBody rest almanac.temperatureToHumidity |> Result.try
            parseAlmanac rest2 parseSeeds { almanac & temperatureToHumidity }

        "humidity-to-location map:" ->
            (humidityToLocation, rest2) <- parseMapBody rest almanac.humidityToLocation |> Result.try
            parseAlmanac rest2 parseSeeds { almanac & humidityToLocation }

        _ ->
            Err InvalidAlmanacSection


expect
    parseSeedsPart1 = \seedsStr ->
        seeds <- seedsStr
            |> Str.split " "
            |> List.mapTry Str.toNat
            |> Result.map

        seed <- List.map seeds
        { start: seed, len: 1 }

    parsed : Almanac
    parsed =
        { seeds : [79, 14, 55, 13]
            |> List.map (\start -> { start, len: 1 })
        , seedToSoil :
            [ { dest: 50, src: 98, len: 2 }
            , { dest: 52, src: 50, len: 48 }
            ]
        , soilToFertilizer :
            [ { dest: 0, src: 15, len: 37 }
            , { dest: 37, src: 52, len: 2 }
            , { dest: 39, src: 0, len: 15 }
            ]
        , fertilizerToWater :
            [ { dest: 49, src: 53, len: 8 }
            , { dest: 0, src: 11, len: 42 }
            , { dest: 42, src: 0, len: 7 }
            , { dest: 57, src: 7, len: 4 }
            ]
        , waterToLight :
            [ { dest: 88, src: 18, len: 7 }
            , { dest: 18, src: 25, len: 70 }
            ]
        , lightToTemperature :
            [ { dest: 45, src: 77, len: 23 }
            , { dest: 81, src: 45, len: 19 }
            , { dest: 68, src: 64, len: 13 }
            ]
        , temperatureToHumidity :
            [ { dest: 0, src: 69, len: 1 }
            , { dest: 1, src: 0, len: 69 }
            ]
        , humidityToLocation :
            [ { dest: 60, src: 56, len: 37 }
            , { dest: 56, src: 93, len: 4 }
            ]
        }

    result = parseAlmanac example parseSeedsPart1 emptyAlmanac
    
    result == Ok parsed


parseMapBody : Str, Map -> Result (Map, Str) [InvalidMapEntry, InvalidNumStr]
parseMapBody = \str, map ->
    (line, rest) = chompLine str

    if Str.isEmpty line then
        Ok (map, rest)

    else
        entry <- line |> parseMapEntry |> Result.try
        parseMapBody rest (List.append map entry)


expect
    src =
        """
        0 15 37
        37 52 2
        39 0 15

        fertilizer-to-water-map:
        """

    expected = 
        [ { dest: 0, src: 15, len: 37 }
        , { dest: 37, src: 52, len: 2 }
        , { dest: 39, src: 0, len: 15 }
        ]
        
    parseMapBody src [] == Ok (expected, "fertilizer-to-water-map:")


parseMapEntry : Str -> Result MapEntry [InvalidMapEntry, InvalidNumStr]
parseMapEntry = \line ->
    when Str.split line " " is
        [destStr, srcStr, lenStr] ->
            dest <- destStr |> Str.toNat |> Result.try
            src <- srcStr |> Str.toNat |> Result.try
            len <- lenStr |> Str.toNat |> Result.try
            Ok { dest, src, len }

        _ ->
            Err InvalidMapEntry

expect parseMapEntry "50 98 2" == Ok { dest: 50, src: 98, len: 2 }
expect parseMapEntry "4198568522 3340289798 96398774" == Ok { dest: 4198568522, src: 3340289798, len: 96398774 }


chompLine : Str -> (Str, Str)
chompLine = \str ->
    when str |> Str.splitFirst "\n" is
        Ok { before, after } -> (before, after)
        Err NotFound -> (str, "")
