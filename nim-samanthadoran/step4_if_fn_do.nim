import reader, printer, nre, types, tables, future, env

proc READ(input: string): malData
proc eval_ast(ast: malData, env: Env): malData
proc EVAL(ast: malData, env: Env): malData
proc PRINT(ast: malData): string
proc rep(input: string, env: Env): string


proc READ(input: string): malData =
  result = read_str(input)


discard """
proc eval_ast(ast: malData, env: Env): malData =
  case ast.malType
  #Deviates from mal guide, but we'll have to make due
  of malSymbol:
    if env.find(ast.sym) != nil:
      let val = env.getvar(ast.sym)(@[])
      if val.malType == malNil:
        result = ast
      else:
        result = val
    else:
      result = ast
  of malList:
    var mList = malData(malType: malList, kind: malList, list: @[])
    for i in ast.list:
      mList.list.add(EVAL(i, env))
    result = mList
  else:
    result = ast
"""
proc eval_ast(ast: malData, env: Env): malData =
  case ast.malType
  of malSymbol:
    result = env.getvar(ast.sym)
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
        let evaluatedList = eval_ast(ast, env)
        env.setvar(ast.list[1].sym, evaluatedList.list[2])
        result = env.getvar(ast.list[1].sym)
      of "let*":
        var innerEnv = initEnv(outer = env)
        let binds = ast.list[1]
        for i in countup(0, len(binds.list) - 2, 2):
          let bindEval = EVAL(binds.list[i + 1], innerEnv)
          innerEnv.setVar(binds.list[i].sym, bindEval)
        result = EVAL(ast.list[2], innerEnv)
      of "if":
        let evaluatedList = eval_ast(ast, env)
        let conditional = evaluatedList.list[1]

        var branch: bool = false

        #Automatically false
        if conditional.malType == malNil:
          branch = false
        #Check the value..
        elif conditional.malType == malBool:
          if conditional.boolean:
            branch = true
          else:
            branch = false
        #Anything else is 'true'
        else:
          branch = true

        if branch:
          result = EVAL(ast.list[2], env)
        else:
          if len(ast.list) > 2:
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
  result = pr_str(ast)

proc rep(input: string, env: Env): string =
  result = PRINT(EVAL(READ(input), env))

proc makeInitialEnv(): Env =
  #Gross and messy function to make our initial environment
  result = initEnv(nil)
  var malProc = malData(malType: malFunc, kind: malFunc, p: nil)
  malProc.p = proc(nodes: varargs[malData]): malData =
    if len(nodes) == 0:
      result = malData(malType: malNil, kind: malNil)
    else:
      var acc: int = nodes[0].num
      for i in 1..<len(nodes):
        acc += nodes[i].num
      result = malData(malType: malNumber, kind: malNumber, num: acc)
  result.setvar("+", malProc)
  malProc = malData(malType: malFunc, kind: malFunc, p: nil)
  malProc.p = proc(nodes: varargs[malData]): malData =
    if len(nodes) == 0:
      result = malData(malType: malNil, kind: malNil)
    else:
      var acc: int = nodes[0].num
      for i in 1..<len(nodes):
        acc -= nodes[i].num
      result = malData(malType: malNumber, kind: malNumber, num: acc)
  result.setvar("-", malProc)
  malProc = malData(malType: malFunc, kind: malFunc, p: nil)
  malProc.p = proc(nodes: varargs[malData]): malData =
    if len(nodes) == 0:
      result = malData(malType: malNil, kind: malNil)
    else:
      var acc: int = nodes[0].num
      for i in 1..<len(nodes):
        acc *= nodes[i].num
      result = malData(malType: malNumber, kind: malNumber, num: acc)
  result.setvar("*", malProc)
  malProc = malData(malType: malFunc, kind: malFunc, p: nil)
  malProc.p = proc(nodes: varargs[malData]): malData =
    if len(nodes) == 0:
      result = malData(malType: malNil, kind: malNil)
    else:
      var acc: int = nodes[0].num
      for i in 1..<len(nodes):
        acc = acc div nodes[i].num
      result = malData(malType: malNumber, kind: malNumber, num: acc)
  result.setvar("/", malProc)

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
