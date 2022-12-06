import std/[sequtils, strutils]
import system/[io, iterators]

type
  Shape = enum
    rock, paper, scissors


func sensibleMod(x: int8, m: int8): uint8 =
  # this will only work in the context of this problem but I do not care.
  if x < 0:
    return uint8(x + m) mod uint8(m)
  else:
    return uint8(x) mod uint8(m)


# gonna return a TRIPLE OH YEAH of the elf moves, part one strategy, and part two strategy
func parseInput(guide: string): (seq[Shape], seq[Shape], seq[Shape]) =
  var
    elfMoves: seq[Shape] = @[]
    partOneStrat: seq[Shape] = @[]
    partTwoStrat: seq[Shape] = @[]
  for round in guide.strip.splitLines:
    let
      moves = splitWhitespace(round)
      elfMove = uint8(moves[0][0]) - uint8('A')
      yourApproach = moves[1][0]

    elfMoves.add(Shape(elfMove))
    partOneStrat.add(Shape(uint8(yourApproach) - uint8('X')))
    # this code is fuzzy because of all the casting, but basically
    # yourApproach - 'Y' is in the set {-1, 0, 1}, and you can add that value
    # to the elf's move and mod it (unsigned, so -1 mod 3 = 2 because -3 + 2 = -1)
    let yourMove = uint8(sensibleMod(int8(elfMove) + int8(yourApproach) - int8('Y'), 3))
    partTwoStrat.add(Shape(yourMove))

  (elfMoves, partOneStrat, partTwoStrat)


func tallyScore(guide: openArray[Round]): int =
  result = 0
  for (elf, you) in guide.items:
    result += ord(you) + 1
    if elf == you:
      result += 3
    elif (ord(elf) + 1) mod 3 == ord(you):
      result += 6


# const inputFile = "test_input"
const inputFile = "puzzle_input"

when isMainModule:
  let (elfMoves, partOneStrat, partTwoStrat) = parseInput io.readFile(inputFile)
  echo "Part One: " & $tallyScore(zip(elfMoves, partOneStrat))
  echo "Part Two: " & $tallyScore(zip(elfMoves, partTwoStrat))
