type
  malKind* = enum
    malNumber,
    malSymbol,
    malString,
    malNil,
    malBool,
    malList

  malDataObj = object
    malType*: malKind
    case kind*: malKind
    of malNumber:
      num*: int
    of malSymbol:
      sym*: string
    of malString:
      str*: string
    of malNil:
      discard
    of malBool:
      boolean*: bool
    of malList:
      list*: seq[malData]

  malData* = ref malDataObj
