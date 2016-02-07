import nre, types, strutils, options, typetraits

let malMatch = r"""[\s,]*(~@|[\[\]{}()'`~^@]|\"(?:[\\].|[^\\\"])*\"|;.*|[^\s\[\]{}()'\"`@,;]+)"""

type
  ReaderObj = object
    position: int
    tokens: seq[string]
  Reader = ref ReaderObj

proc next(reader: Reader)
proc peek(reader: Reader): string
proc read_form(reader: Reader): malData
proc read_list(reader: Reader): seq[malData]
proc read_atom(reader: Reader): malData
proc read_string(reader: Reader): malData
proc tokenizer(input: string): seq[string]
proc read_str*(input: string): malData

proc next(reader: Reader) =
  #Move the 'iterator' along
  inc(reader.position)

proc peek(reader: Reader): string =
  #Look at the current token without consuming it
  result = reader.tokens[reader.position]

proc read_form(reader: Reader): malData =
  #Function to call the appropriate reader
  if reader.position >= len(reader.tokens):
    result = malData(malType: malNil, kind: malNil)
  else:
    case peek(reader)
    #It's a list...
    of "(", "[":
      #Get off of the opening parentheses here for sanity
      next(reader)

      result = malData(malType: malList, kind: malList, list: read_list(reader))
    #It's anything but a list...
    else:
      result =
        if peek(reader)[0] == '"':
          read_string(reader)
        else:
          read_atom(reader)

proc read_string(reader: Reader): malData =
  let originalString = peek(reader)
  var workingString = ""
  next(reader)

  var position = 1
  while position < len(originalString) - 1:
    if originalString[position] == '\\':
      inc(position)
      case originalString[position]
      of '\\':
        workingString &= $chr(92)
      of 'n':
        #Because nim won't allow \n in character literals
        workingString &= $chr(10)
      of '\"':
        workingString &= $chr(34)
      else:
        discard
    else:
      workingString &= $originalString[position]

    inc(position)

  result = malData(malType: malString, kind: malString, str: workingString)

proc read_atom(reader: Reader): malData =
  let val = peek(reader)
  try:
    result = malData(malType: malNumber, kind: malNumber, num: parseInt(val))
    next(reader)
  except ValueError:
    #Keep track of things...
    next(reader)

    if val == "nil":
      result = malData(malType: malNil, kind: malNil)
    elif val.toLower() == "true" or val.toLower() == "false":
      result = malData(malType: malBool, kind: malBool, boolean: parseBool(val.toLower()))
    else:
      #Account for special symbols
      case val
      of "'":
        var list: seq[malData] = @[]
        list.add(malData(malType: malSymbol, kind: malSymbol, sym: "quote"))
        list.add(read_form(reader))
        result = malData(malType: malList, kind: malList, list: list)

      of "`":
        var list: seq[malData] = @[]
        list.add(malData(malType: malSymbol, kind: malSymbol, sym: "quasiquote"))
        list.add(read_form(reader))
        result = malData(malType: malList, kind: malList, list: list)

      of "~":
        var list: seq[malData] = @[]
        list.add(malData(malType: malSymbol, kind: malSymbol, sym: "unquote"))
        list.add(read_form(reader))
        result = malData(malType: malList, kind: malList, list: list)

      of "~@":
        var list: seq[malData] = @[]
        list.add(malData(malType: malSymbol, kind: malSymbol, sym: "splice-unquote"))
        list.add(read_form(reader))
        result = malData(malType: malList, kind: malList, list: list)

      else:
        result = malData(malType: malSymbol, kind: malSymbol, sym: val)


proc read_list(reader: Reader): seq[malData] =
  #Allocate space for our list
  result = newSeq[malData]()

  #While we haven't closed this list...
  while peek(reader) != ")" and peek(reader) != "]" and reader.position < len(reader.tokens):
    #Read the form as appropriate
    var toAdd = read_form(reader)
    if toAdd != nil:
      result.add(toAdd)
    else:
      break

  if reader.position < len(reader.tokens):
    if peek(reader) == ")" or peek(reader) == "]":
      next(reader)
  else:
    discard
    #TODO:Throw an exception due to mismatched parentheses

proc tokenizer(input: string): seq[string] =
  result = input.findAll(nre.re(malMatch))

  #Really gross way to fix whitespace problem
  var toStrip: set[char] = {' ', ','}
  for i in 0..<len(result):
    result[i] = result[i].strip(true, true, toStrip)

proc read_str(input: string): malData =
  let tokens = tokenizer(input)
  var reader: Reader = Reader(position: 0, tokens: tokens)

  result = read_form(reader)
