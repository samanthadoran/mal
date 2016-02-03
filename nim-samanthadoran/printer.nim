import types, strutils
proc pr_str*(input: malData): string =
  #Just to make sure
  if input == nil:
    return nil
  case input.malType
  of malNumber:
    result = $input.num
  of malNil:
    result = "nil"
  of malBool:
    result = $input.boolean
  of malSymbol:
    result = input.sym
  of malList:
    var sSeq: seq[string] = @[]
    for i in 0..<len(input.list):
      sSeq.add(pr_str(input.list[i]))
    result = "(" & sSeq.join(" ") & ")"
  else:
    #Ignore for now...
    #Strings and such
    discard
