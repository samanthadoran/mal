proc READ(input: string): string =
  result = input
  discard

proc EVAL(input: string): string =
  result = input
  discard

proc PRINT(input: string): string =
  result = input
  discard

proc rep(input: string): string =
  result = READ(EVAL(PRINT(input)))

while true:
  stdout.write "user> "
  let input = readline(stdin)
  echo(rep(input))
