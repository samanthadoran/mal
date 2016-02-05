#TODO: Change envvars to be of type Table[string, malData] to accompany switch to
#malData to include a function

import types, tables, sequtils
type
  Env* = ref envObj
  envObj = object
    #envvars: Table[string, proc(nodes: varargs[malData]): malData {.closure}]
    envvars: Table[string, malData]
    outer*: Env

#proc setvar*(e: Env, s: string, p: proc(nodes: varargs[malData]): malData {.closure})
proc setvar*(e: Env, key: string, value: malData)


proc initEnv*(outer: Env, binds: malData = nil, expressions: malData = nil): Env =
  result = new envObj
  #result.envvars = initTable[string, proc(nodes: varargs[malData]): malData]()
  result.envvars = initTable[string, malData]()
  result.outer = outer
  if binds != nil and expressions != nil:
    var bindsList: seq[malData] = @[]
    var exprList: seq[malData] = @[]

    #If we weren't passed a list, make it one
    if binds.malType != malList:
      bindsList.add(binds)
    else:
      bindsList = binds.list
    if expressions.malType != malList:
      exprList.add(expressions)
    else:
      exprList = expressions.list

    for i in zip(bindsList, exprList):
      #setvar(result, i.a.sym, proc(nodes: varargs[malData]): malData = result =i.b)
      setvar(result, i.a.sym, i.b)

proc setvar*(e: Env, key: string, value: malData) =
  e.envvars[key] = value


proc find*(e: Env, s: string): Env =
  #Determine if an environment variable exists, return the environment it exists in
  if e.envvars.hasKey(s):
    result = e
  else:
    if e.outer == nil:
      result = nil
      #echo("Could not find containing environment")
    else:
      result = find(e.outer, s)

#proc getvar*(e: Env, s: string): proc(nodes: varargs[malData]): malData {.closure} =
proc getvar*(e: Env, s: string): malData =
  #Find and return an environment variable
  if e.envvars.hasKey(s):
    result = e.envvars[s]
  else:
    if e.outer == nil:
      echo("Could not find environment variable!")
    else:
      result = getvar(e.outer, s)
