type
  malKind* = enum
    malNumber,
    malSymbol,
    malList

  malDataObj = object
    malType*: malKind
    case kind*: malKind
    of malNumber:
      num*: int
    of malSymbol:
      sym*: string
    of malList:
      list*: seq[malData]

  malData* = ref malDataObj
