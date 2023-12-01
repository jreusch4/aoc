app "hello"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.6.2/c7T4Hp8bAdWz3r9ZrhboBzibCjJag8d0IP_ljb42yVc.tar.br" }
    imports [pf.Stdout, "inputs/day1.txt" as input : Str]
    provides [main] to pf

# example = "1abc2\npqr3stu8vwx\na1b2c3d4e5f\ntreb7uchet"

main =
    calibrations =
        lines = input |> Str.split "\n"
        line <- List.keepOks lines
        numbers = line |> Str.graphemes |> List.keepOks Str.toI32
        first <- List.first numbers |> Result.try
        last <- List.last numbers |> Result.try

        Ok (first * 10 + last)


    Stdout.line "Sum of calibration numbers: \(List.sum calibrations |> Num.toStr)"

