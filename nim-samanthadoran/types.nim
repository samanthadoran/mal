type
  malKind* = enum
    malNumber,
    malSymbol,
    malFunc,
    malString,
    malNil,
    malBool,
    malList

  malDataObj = object
  #Object variant for the various maltypes we encounter
    malType*: malKind
    case kind*: malKind
    of malNumber:
      num*: int
    of malSymbol:
      sym*: string
    of malFunc:
      p*: proc(nodes: varargs[malData]): malData {.closure}
    of malString:
      str*: string
    of malNil:
      discard
    of malBool:
      boolean*: bool
    of malList:
      list*: seq[malData]

  malData* = ref malDataObj
