import reader, printer, nre, types, tables, future

proc READ(input: string): malData
proc eval_ast(ast: malData, env: var Table[string, proc(nodes: openarray[malData]): malData {.closure}]): malData
proc EVAL(ast: malData, env: var Table[string, proc(nodes: openarray[malData]): malData {.closure}]): malData
proc PRINT(ast: malData): string
proc rep(input: string, env: var Table[string, proc(nodes: openarray[malData]): malData {.closure}]): string


proc READ(input: string): malData =
  result = read_str(input)

proc eval_ast(ast: malData, env: var Table[string, proc(nodes: openarray[malData]): malData {.closure}]): malData =
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

proc EVAL(ast: malData, env: var Table[string, proc(nodes: openarray[malData]): malData {.closure}]): malData =
  case ast.malType
  of malList:
    #If it is a list, we need to pass it down to eval_ast so it evaluates it recursively
    let mList = eval_ast(ast, env)
    let lenList = len(mList.list)
    let firstKey = mList.list[0]

    #It's a symbol, we have to do some operations
    if firstKey.malType == malSymbol:
      if env.hasKey(firstKey.sym):
        result = env[firstKey.sym](mList.list[1..<lenList])
      #TODO: Throw an exception here!
      else:
        echo(mList.list[0].sym, " not found.")
    #It's just a list, return it sanely
    else:
      result = mList
  else:
    #It is something other than a list, just have eval_ast do its magic
    result = eval_ast(ast, env)

proc PRINT(ast: malData): string =
  result = pr_str(ast)

proc rep(input: string, env: var Table[string, proc(nodes: openarray[malData]): malData]): string =
  result = PRINT(EVAL(READ(input), env))

proc makeInitialEnv(): Table[string, proc(nodes: openarray[malData]): malData] =
  #Gross and messy function to make our initial environment
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
  #Keep our initial environment
  var env = makeInitialEnv()
  while true:
    stdout.write "user> "
    let input = readline(stdin)
    let output = rep(input, env)
    if output != nil:
      echo(output)
main()
