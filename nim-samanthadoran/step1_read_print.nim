import reader, printer, nre, types

proc READ(input: string): malData =
  result = read_str(input)

proc EVAL(input: malData): malData =
  result = input

proc PRINT(input: malData): string =
  result = pr_str(input)

proc rep(input: string): string =
  result = PRINT(EVAL(READ(input)))

while true:
  stdout.write "user> "
  let input = readline(stdin)
  echo(rep(input))
