import types, tables
type
  Env* = ref envObj
  envObj = object
    envvars: Table[string, proc(nodes: openarray[malData]): malData {.closure}]
    outer*: Env

proc initEnv*(outer: Env): Env =
  result = new envObj
  result.envvars = initTable[string, proc(nodes: openarray[malData]): malData]()
  result.outer = outer

proc setvar*(e: Env, s: string, p: proc(nodes: openarray[malData]): malData {.closure}) =
  #Set an environment variable
  e.envvars[s] = p

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

proc getvar*(e: Env, s: string): proc(nodes: openarray[malData]): malData {.closure} =
  #Find and return an environment variable
  if e.envvars.hasKey(s):
    result = e.envvars[s]
  else:
    if e.outer == nil:
      echo("Could not find environment variable!")
    else:
      result = getvar(e.outer, s)
