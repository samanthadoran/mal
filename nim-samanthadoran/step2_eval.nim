import reader, printer, nre, types, tables, future

var repl_env: Table[string, proc(nodes: openarray[malData]): malData]
repl_env = initTable[string, proc(nodes: openarray[malData]): malData]()

repl_env.add("+", proc(nodes: openarray[malData]): malData =
  var acc: int = nodes[0].num
  for i in 1..<len(nodes):
    acc += nodes[i].num
  result = malData(malType: malNumber, kind: malNumber, num: acc)
)

repl_env.add("-", proc(nodes: openarray[malData]): malData =
  var acc: int = nodes[0].num
  for i in 1..<len(nodes):
    acc -= nodes[i].num
  result = malData(malType: malNumber, kind: malNumber, num: acc)
)

repl_env.add("*", proc(nodes: openarray[malData]): malData =
  var acc: int = nodes[0].num
  for i in 1..<len(nodes):
    acc *= nodes[i].num
  result = malData(malType: malNumber, kind: malNumber, num: acc)
)

repl_env.add("/", proc(nodes: openarray[malData]): malData =
  var acc: int = nodes[0].num
  for i in 1..<len(nodes):
    acc = acc div nodes[i].num
  result = malData(malType: malNumber, kind: malNumber, num: acc)
)

proc READ(input: string): malData
proc eval_ast(ast: malData, env: Table[string, proc(nodes: openarray[malData]): malData {.closure}]): malData
proc EVAL(ast: malData, env: Table[string, proc(nodes: openarray[malData]): malData {.closure}]): malData
proc PRINT(ast: malData): string
proc rep(input: string, env: Table[string, proc(nodes: openarray[malData]): malData {.closure}]): string


proc READ(input: string): malData =
  result = read_str(input)

proc eval_ast(ast: malData, env: Table[string, proc(nodes: openarray[malData]): malData {.closure}]): malData =
  case ast.malType
  #Deviates from mal guide, but we'll have to make due
  of malSymbol:
    result = ast
  of malList:
    result = malData(malType: malList, kind: malList, list: @[])
    for i in ast.list:
      result.list.add(EVAL(i, env))
  else:
    result = ast

proc EVAL(ast: malData, env: Table[string, proc(nodes: openarray[malData]): malData {.closure}]): malData =
  case ast.malType
  of malList:
    let mList = eval_ast(ast, env)
    let lenList = len(mList.list)
    let firstKey = mList.list[0]
    if firstKey.malType == malSymbol:
      if repl_env.hasKey(firstKey.sym):
        result = repl_env[firstKey.sym](mList.list[1..<lenList])
      #TODO: Throw an exception here!
      else:
        echo(mList.list[0].sym, " not found.")
    else:
      result = mList
  else:
    result = eval_ast(ast, env)

proc PRINT(ast: malData): string =
  result = pr_str(ast)

proc rep(input: string, env: Table[string, proc(nodes: openarray[malData]): malData]): string =
  result = PRINT(EVAL(READ(input), env))

proc makeInitialEnv(): Table[string, proc(nodes: openarray[malData]): malData] =
  result = initTable[string, proc(nodes: openarray[malData]): malData]()
  result.add("+", proc(nodes: openarray[malData]): malData =
    var acc: int = nodes[0].num
    for i in 1..<len(nodes):
      acc += nodes[i].num
    result = malData(malType: malNumber, kind: malNumber, num: acc)
  )

  result.add("-", proc(nodes: openarray[malData]): malData =
    var acc: int = nodes[0].num
    for i in 1..<len(nodes):
      acc -= nodes[i].num
    result = malData(malType: malNumber, kind: malNumber, num: acc)
  )

  result.add("*", proc(nodes: openarray[malData]): malData =
    var acc: int = nodes[0].num
    for i in 1..<len(nodes):
      acc *= nodes[i].num
    result = malData(malType: malNumber, kind: malNumber, num: acc)
  )

  result.add("/", proc(nodes: openarray[malData]): malData =
    var acc: int = nodes[0].num
    for i in 1..<len(nodes):
      acc = acc div nodes[i].num
    result = malData(malType: malNumber, kind: malNumber, num: acc)
  )

proc main() =
  var env = makeInitialEnv()
  while true:
    stdout.write "user> "
    let input = readline(stdin)
    let output = rep(input, env)
    if output != nil:
      echo(output)
main()
