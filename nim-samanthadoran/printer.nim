import types, strutils
proc pr_str*(input: malData): string =
  case input.malType
  of malNumber:
    result = $input.num
  of malSymbol:
    result = input.sym
  of malList:
    var sSeq: seq[string] = @[]
    for i in 0..<len(input.list):
      sSeq.add(pr_str(input.list[i]))
    result = "(" & sSeq.join(" ") & ")"
