import tables, types, future

var ns*: Table[string, malData] = initTable[string, malData]()

ns["="] = malData(malType: malFunc, kind: malFunc, p: proc(nodes: varargs[malData]): malData =
  if nodes.len() == 0:
    result = malData(malType: malNil, kind: malNil)
  else:
    let firstNode = nodes[0]
    var allSame: bool = true
    for i in 1..<len(nodes):
      if nodes[i].malType != firstNode.malType:
        allSame = false
        break
    if not allSame:
      result = malData(malType: malBool, kind: malBool, boolean: false)
    else:
      case firstNode.malType
      of malList:
        for i in 1..<len(nodes):
          if len(nodes[i].list) != len(firstNode.list):
            allSame = false
            break

        #Don't iterate over empty lists
        if len(nodes[0].list) == 0 and allSame:
          return malData(malType: malBool, kind: malBool, boolean: true)

        if allSame:
          for i in 0..<len(nodes[0].list):
            for j in 0..<len(nodes):
              if not ns["="].p(nodes[0].list[i], nodes[j].list[i]).boolean:
                allSame = false
                break
        result = malData(malType: malBool, kind: malBool, boolean: allSame)
      of malFunc:
        result = malData(malType: malNil, kind: malNil)
      of malNumber:
        for i in 1..<len(nodes):
          if nodes[i].num != firstNode.num:
            allSame = false
            break
        result = malData(malType: malBool, kind: malBool, boolean: allSame)
      of malSymbol:
        for i in 1..<len(nodes):
          if nodes[i].sym != firstNode.sym:
            allSame = false
            break
        result = malData(malType: malBool, kind: malBool, boolean: allSame)
      of malBool:
        for i in 1..<len(nodes):
          if nodes[i].boolean != firstNode.boolean:
            allSame = false
            break
        result = malData(malType: malBool, kind: malBool, boolean: allSame)
      of malNil:
        result = malData(malType: malBool, kind: malBool, boolean: true)
      of malString:
        for i in 1..<len(nodes):
          if nodes[i].str != firstNode.str:
            allSame = false
            break
        result = malData(malType: malBool, kind: malBool, boolean: allSame)
)

#The inequality operators assume that the arguments they are passed are numbers.
ns["<="] = malData(malType: malFunc, kind: malFunc, p: proc(nodes: varargs[malData]): malData =
  if nodes.len() == 0:
    result = malData(malType: malNil, kind: malNil)
  else:
    result = malData(malType: malBool, kind: malBool, boolean: nodes[0].num <= nodes[1].num)
)
ns["<"] = malData(malType: malFunc, kind: malFunc, p: proc(nodes: varargs[malData]): malData =
  if nodes.len() == 0:
    result = malData(malType: malNil, kind: malNil)
  else:
    result = malData(malType: malBool, kind: malBool, boolean: nodes[0].num < nodes[1].num)
)
ns[">="] = malData(malType: malFunc, kind: malFunc, p: proc(nodes: varargs[malData]): malData =
  if nodes.len() == 0:
    result = malData(malType: malNil, kind: malNil)
  else:
    result = malData(malType: malBool, kind: malBool, boolean: nodes[0].num >= nodes[1].num)
)
ns[">"] = malData(malType: malFunc, kind: malFunc, p: proc(nodes: varargs[malData]): malData =
  if nodes.len() == 0:
    result = malData(malType: malNil, kind: malNil)
  else:
    result = malData(malType: malBool, kind: malBool, boolean: nodes[0].num > nodes[1].num)
)

ns["+"] = malData(malType: malFunc, kind: malFunc, p: proc(nodes: varargs[malData]): malData =
  if nodes.len() == 0:
    result = malData(malType: malNil, kind: malNil)
  else:
    result = malData(malType: malNumber, kind: malNumber, num: nodes[0].num)
    for i in 1..<len(nodes):
      result.num += nodes[i].num
)

ns["-"] = malData(malType: malFunc, kind: malFunc, p: proc(nodes: varargs[malData]): malData =
  if nodes.len() == 0:
    result = malData(malType: malNil, kind: malNil)
  else:
    result = malData(malType: malNumber, kind: malNumber, num: nodes[0].num)
    for i in 1..<len(nodes):
      result.num -= nodes[i].num
)
ns["/"] = malData(malType: malFunc, kind: malFunc, p: proc(nodes: varargs[malData]): malData =
  if nodes.len() == 0:
    result = malData(malType: malNil, kind: malNil)
  else:
    result = malData(malType: malNumber, kind: malNumber, num: nodes[0].num)
    for i in 1..<len(nodes):
      result.num = result.num div nodes[i].num
)

ns["*"] = malData(malType: malFunc, kind: malFunc, p: proc(nodes: varargs[malData]): malData =
  if nodes.len() == 0:
    result = malData(malType: malNil, kind: malNil)
  else:
    result = malData(malType: malNumber, kind: malNumber, num: nodes[0].num)
    for i in 1..<len(nodes):
      result.num *= nodes[i].num
)

ns["list"] = malData(malType: malFunc, kind: malFunc, p: proc(nodes: varargs[malData]): malData =
  result = malData(malType: malList, kind: malList, list: @[])
  for i in nodes:
    result.list.add(i)
)

ns["list?"] = malData(malType: malFunc, kind: malFunc, p: proc(nodes: varargs[malData]): malData =
  if nodes.len() == 0 or nodes[0].malType != malList:
    result = malData(malType: malNil, kind: malNil)
  else:
    result = malData(malType: malBool, kind: malBool, boolean: nodes[0].malType == malList)
)

ns["empty?"] = malData(malType: malFunc, kind: malFunc, p: proc(nodes: varargs[malData]): malData =
  if nodes.len() == 0 or nodes[0].malType != malList:
    result = malData(malType: malNil, kind: malNil)
  else:
    result = malData(malType: malBool, kind: malBool, boolean: len(nodes[0].list) == 0)
)
ns["count"] = malData(malType: malFunc, kind: malFunc, p: proc(nodes: varargs[malData]): malData =
  if nodes.len() == 0 or nodes[0].malType != malList:
    result = malData(malType: malNil, kind: malNil)
  else:
    result = malData(malType: malNumber, kind: malNumber, num: len(nodes[0].list))
)
