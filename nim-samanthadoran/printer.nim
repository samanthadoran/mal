import types, strutils
proc pr_str*(input: malData, printReadably: bool): string =
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
  of malString:
    if not printReadably:
      result = input.str
    else:
      let originalString = input.str
      var workingString = "\""

      var position = 0
      while position < len(originalString):
        case originalString[position]
        of '\\':
          workingString &= "\\\\"
        of '\"':
          workingString &= "\\\""
        of chr(10):
          workingString &= "\\n"
        else:
          workingString &= $originalString[position]

        inc(position)

      result = workingString & "\""

  of malFunc:
    result = "#FUNCTION"
  of malList:
    var sSeq: seq[string] = @[]
    for i in 0..<len(input.list):
      sSeq.add(pr_str(input.list[i], printReadably))
    result = "(" & sSeq.join(" ") & ")"
  else:
    result = "\"\""
