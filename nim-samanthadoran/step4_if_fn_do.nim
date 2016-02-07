import reader, printer, nre, types, tables, future, env, core

proc READ(input: string): malData
proc eval_ast(ast: malData, env: Env): malData
proc EVAL(ast: malData, env: Env): malData
proc PRINT(ast: malData): string
proc rep(input: string, env: Env): string


proc READ(input: string): malData =
  result = read_str(input)

proc eval_ast(ast: malData, env: Env): malData =
  case ast.malType
  of malSymbol:
    if env.find(ast.sym) != nil:
      result = env.getvar(ast.sym)
    else:
      result = ast
  of malList:
    result = malData(malType: malList, kind: malList, list: @[])
    for i in ast.list:
      result.list.add(EVAL(i, env))
  else:
    result = ast


proc EVAL(ast: malData, env: ENV): malData =
  result = nil
  if ast.malType != malList:
    result = eval_ast(ast, env)
  else:
    if ast.list[0].malType == malSymbol:
      case ast.list[0].sym
      of "def!":
        #Take special care to not lookup the bad symbols
        let listToEval = malData(malType: malList, kind: malList, list: ast.list[2..<len(ast.list)])
        let evaluatedList = eval_ast(listToEval, env)
        env.setvar(ast.list[1].sym, evaluatedList.list[0])
        result = env.getvar(ast.list[1].sym)
      of "let*":
        var innerEnv = initEnv(outer = env)
        let binds = ast.list[1]
        for i in countup(0, len(binds.list) - 2, 2):
          let bindEval = EVAL(binds.list[i + 1], innerEnv)
          innerEnv.setVar(binds.list[i].sym, bindEval)
        result = EVAL(ast.list[2], innerEnv)
      of "if":
        var branch: bool = false

        #Don't forget to evaluate the conditional
        let conditional = EVAL(ast.list[1], env)

        if conditional.malType == malNil:
          branch = false
        elif conditional.malType == malBool:
          branch = conditional.boolean
        else:
          branch = true

        if branch:
          result = EVAL(ast.list[2], env)
        else:
          if len(ast.list) > 3:
            result = EVAL(ast.list[3], env)
          else:
            result = malData(malType: malNil, kind: malNil)
      of "do":
        for i in 1..<len(ast.list):
          result = EVAL(ast.list[i], env)
      of "fn*":
        let r = proc(nodes: varargs[malData]): malData {.closure.} =
          let funcBody = ast.list[2]
          var s = malData(malType: malList, kind: malList, list: @[])
          for i in nodes:
            s.list.add(i)
          var innerEnv = initEnv(outer = env, binds = ast.list[1], expressions = s)
          result = EVAL(funcBody, innerEnv)
        result = malData(malType: malFunc, kind: malFunc, p: r)
      else:
        discard
    if result == nil:
      let evaluatedList = eval_ast(ast, env)
      let firstElement = evaluatedList.list[0]
      result = firstElement.p(evaluatedList.list[1..<len(evaluatedList.list)])

proc PRINT(ast: malData): string =
  result = pr_str(ast, true)

proc rep(input: string, env: Env): string =
  result = PRINT(EVAL(READ(input), env))

proc makeInitialEnv(): Env =
  #Setup our initial environment
  result = initEnv(nil)
  for k,v in ns.pairs():
    result.setvar(k, v)

proc main() =
  #Keep our initial environment
  var env = makeInitialEnv()

  #Define not using the language itself
  discard rep("(def! not (fn* (a) (if a false true)))", env)

  while true:
    stdout.write "user> "
    let input = readline(stdin)
    let output = rep(input, env)
    if output != nil:
      echo(output)

main()
