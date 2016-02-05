import reader, printer, nre, types, tables, future, env

proc READ(input: string): malData
proc eval_ast(ast: malData, env: Env): malData
proc EVAL(ast: malData, env: Env): malData
proc PRINT(ast: malData): string
proc rep(input: string, env: Env): string


proc READ(input: string): malData =
  result = read_str(input)

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

proc EVAL(ast: malData, env: Env): malData =
  case ast.malType
  of malList:
    #Get the first key, avoid evaluating the list until we are sure the
    #environment won't be changing.
    #TODO: Consider a method of not having to write the calculation of that
    #value three times. Preferably without causing a crash due to change in env.
    let firstKey = ast.list[0]

    #It's a symbol, we have to do some operations
    if firstKey.malType == malSymbol:
      case firstKey.sym
      #Adds to the current environment
      of "def!":
        let mList = eval_ast(ast, env)

        #Be careful to use the ast.list[1], the other one has already been replaced from env`
        env.setvar(ast.list[1].sym, proc(nodes: openarray[malData]): malData = result = mList.list[2])
        result = env.getvar(ast.list[1].sym)(@[])

      #Creates a new environment and evalutes proceeding statements with it
      of "let*":
        var innerEnv = initEnv(env)
        let binds = ast.list[1]
        for i in countup(0, len(binds.list) - 2, 2):
          let bindEval = EVAL(binds.list[i + 1], innerEnv)
          innerEnv.setVar(binds.list[i].sym,
                  proc(nodes: openarray[malData]): malData = result = bindEval)
        result = EVAL(ast.list[2], innerEnv)

      #See if we can find the right function
      else:
        let mList = eval_ast(ast, env)
        let lenList = len(mList.list)
        let fEnv = env.find(firstKey.sym)
        if fEnv != nil:
          result = fEnv.getvar(firstKey.sym)(mList.list[1..<lenList])
        #TODO: Throw an exception here!
        else:
          discard
    #It's just a list, return it sanely
    else:
      let mList = eval_ast(ast, env)
      result = mList
  else:
    #It is something other than a list, just have eval_ast do its magic
    result = eval_ast(ast, env)

proc PRINT(ast: malData): string =
  result = pr_str(ast)

proc rep(input: string, env: Env): string =
  result = PRINT(EVAL(READ(input), env))

proc makeInitialEnv(): Env =
  #Gross and messy function to make our initial environment
  result = initEnv(nil)
  result.setvar("+", proc(nodes: openarray[malData]): malData =
    if len(nodes) == 0:
      result = malData(malType: malNil, kind: malNil)
    else:
      var acc: int = nodes[0].num
      for i in 1..<len(nodes):
        acc += nodes[i].num
      result = malData(malType: malNumber, kind: malNumber, num: acc)
  )

  result.setvar("-", proc(nodes: openarray[malData]): malData =
    if len(nodes) == 0:
      result = malData(malType: malNil, kind: malNil)
    else:
      var acc: int = nodes[0].num
      for i in 1..<len(nodes):
        acc -= nodes[i].num
      result = malData(malType: malNumber, kind: malNumber, num: acc)
  )

  result.setvar("*", proc(nodes: openarray[malData]): malData =
    if len(nodes) == 0:
      result = malData(malType: malNil, kind: malNil)
    else:
      var acc: int = nodes[0].num
      for i in 1..<len(nodes):
        acc *= nodes[i].num
      result = malData(malType: malNumber, kind: malNumber, num: acc)
  )

  result.setvar("/", proc(nodes: openarray[malData]): malData =
    if len(nodes) == 0:
      result = malData(malType: malNil, kind: malNil)
    else:
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
