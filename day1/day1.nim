import std/[strutils, parseutils]
import system/io

proc partOne(input: string): void =
  var maxElf = 0
  for elf in input.split("\n\n"):
    let elf = elf.strip
    var thisElfCals = 0
    for food in elf.splitLines:
      var calories: int
      let _ = parseInt(food, calories)
      thisElfCals += calories

    if thisElfCals > maxElf:
      maxElf = thisElfCals

  echo("Part One: " & $maxElf)

func sum(xs: openArray[int]): int =
  result = 0
  for x in xs:
    result += x

proc partTwo(input: string): void =
  var topElves = [0, 0, 0]
  for elf in input.split("\n\n"):
    let elf = elf.strip
    var thisElfCals = 0
    for food in elf.splitLines:
      var calories: int
      let _ = parseInt(food, calories)
      thisElfCals += calories

    # Let's be efficient about this, no need to save _every_ elf in memory.
    for i in 0..2:
      if thisElfCals > topElves[i]:
        if i < 2:
          # based slices
          # you've seen C with classes, now I present to you: C with slices.
          topElves[i+1..2] = topElves[i..1]
        topElves[i] = thisElfCals
        break

  echo("Part Two: " & $topElves & ", " & $sum(topElves))


when isMainModule:
  let input = io.readFile("puzzle_input")
  # let input = io.readFile("test_input")
  partOne(input)
  partTwo(input)
