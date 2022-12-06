import std/strutils
import system/io

# don't give this guy anything that isn't in [A..Za..z]
func priority(item: char): range[1..52] =
  if item < 'a':
    return uint8(item) - uint8('A') + 27
  else:
    return uint8(item) - uint8('a') + 1

# Invariant: All rucksacks are of even-length
func partOne(rucksackList: string): int =
  result = 0
  for sack in rucksackList.strip.splitLines:
    let
      firstHalf = sack[0..(len(sack) div 2) - 1]
      secondHalf = sack[(len(sack) div 2)..len(sack) - 1]
    for i in 0..(len(sack) div 2 - 1):
      # Nim is missing loop labelling
      var foundMatch = false
      for j in 0..(len(sack) div 2 - 1):
        if firstHalf[i] == secondHalf[j]:
          result += priority(firstHalf[i])
          foundMatch = true
          break
      if foundMatch:
        break


iterator adv3(upper: int): int =
  var x = 0
  while x < upper:
    yield x
    x += 3


func partTwo(rucksackList: openArray[string]): int =
  result = 0
  # Every three sacks constitute one group
  for i in adv3(len(rucksackList)):
    let
      elf1 = rucksackList[i]
      elf2 = rucksackList[i+1]
      elf3 = rucksackList[i+2]

    for e1 in 0..len(elf1)-1:
      var foundBadge = false
      for e2 in 0..len(elf2)-1:
        if elf1[e1] == elf2[e2]:
          for e3 in 0..len(elf3)-1:
            if elf1[e1] == elf3[e3]:
              result += priority(elf3[e3])
              foundBadge = true
              break

        if foundBadge:
          break

      if foundBadge:
        break


when isMainModule:
  # let input = io.readFile("test_input")
  let input = io.readFile("puzzle_input")
  echo "Part One: " & $partOne(input)
  echo "Part Two: " & $partTwo(input.strip.splitLines)
