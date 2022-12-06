import std/strutils
import system/io

type
  Inst = object
    count:     int
    fromStack: int
    toStack:   int


iterator enumerateStack(artLines: openArray[string], stackIndex: int): char =
  var x = len(artLines) - 2
  while x >= 0 and stackIndex < len(artLines[x]) and artLines[x][stackIndex] != ' ':
    yield artLines[x][stackIndex]
    x -= 1


func parseStartingState(stackASCIIArt: string): seq[seq[char]] =
  # Find how tall the tallest stack is, and how many there are.
  let
    artLines = stackASCIIArt.splitLines
    stackIndexRow = len(artLines) - 1
    noOfStacks = len(artLines[stackIndexRow].splitWhitespace)

  for s in 1..noOfStacks:
    var newStack: seq[char] = @[]
    let stackIndex = 4 * (s - 1) + 1
    for c in enumerateStack(artLines, stackIndex):
      newStack.add(c)
    result.add(newStack)


func parseInstructions(instructions: string): seq[Inst] =
  for instText in instructions.strip.splitLines:
    let
      tokens = instText.splitWhitespace
      count = parseInt(tokens[1])
      fromStack = parseInt(tokens[3])
      toStack = parseInt(tokens[5])

    result.add(Inst(count: count, fromStack: fromStack, toStack: toStack))


func partOne(state: sink seq[seq[char]], insts: seq[Inst]): string =
  # eval instructions
  for i in insts:
    for _ in 1..i.count:
      state[i.toStack-1].add(state[i.fromStack-1].pop)

  # reduce to desired result
  for stack in state:
    result.add(stack[len(stack)-1])


func partTwo(state: sink seq[seq[char]], insts: seq[Inst]): string =
  # eval instructions
  for i in insts:
    let
      hi = len(state[i.fromStack-1]) - 1
      lo = hi - i.count + 1

    state[i.toStack-1] = state[i.toStack-1] & state[i.fromStack-1][lo..hi]
    state[i.fromStack-1].setLen(len(state[i.fromStack-1]) - i.count)

  # reduce to desired result
  for stack in state:
    result.add(stack[len(stack)-1])


when isMainModule:
  let
    input = io.readFile("puzzle_input")
    # input = io.readFile("test_input")
    inputParts = input.split("\n\n")
    instructions = parseInstructions(inputParts[1])
    # I orginally only had "state" and passed it to both assuming it would copy the original
    # `sink` works differently than I expected
    state1 = parseStartingState(inputParts[0])
    state2 = state1

  echo "Part One: " & $partOne(state1, instructions)
  echo "Part Two: " & $partTwo(state2, instructions)
