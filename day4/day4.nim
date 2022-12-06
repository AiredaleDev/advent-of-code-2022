import std/[sequtils, strutils]
import system/io

type
  # SectionList = seq[((range[1..99], range[1..99]), (range[1..99], range[1..99]))]
  SectionList = seq[((int, int), (int, int))] # rip dependent typing


func parsePairs(rangeList: string): SectionList =
  for elfPair in rangeList.strip.splitLines:
    # going more specific to this particular puzzle
    let
      nums = split(elfPair, {',', '-'}).map(parseInt)
      leftElf = (nums[0], nums[1])
      rightElf = (nums[2], nums[3])

    result.add((leftElf, rightElf))


func partOne(elfPairs: SectionList): int =
  result = 0
  for (p1, p2) in elfPairs:
    # why can't I just pattern match these in the for statement?
    let
      (p11, p12) = p1
      (p21, p22) = p2
    if p11 <= p21 and p22 <= p12 or p21 <= p11 and p12 <= p22:
      result += 1


func partTwo(elfPairs: SectionList): int =
  result = 0
  for (p1, p2) in elfPairs:
    # why can't I just pattern match these in the for statement?
    let
      (p11, p12) = p1
      (p21, p22) = p2
      inside = p11 <= p21 and p22 <= p12 or p21 <= p11 and p12 <= p22
      overTheEdge = p11 <= p21 and p21 <= p12 or p11 <= p22 and p22 <= p12
    if inside or overTheEdge:
      result += 1


when isMainModule:
  let
    # input = io.readFile("test_input")
    input = io.readFile("puzzle_input")
    elfPairs = parsePairs(input)
  echo "Part One: " & $partOne(elfPairs)
  echo "Part Two: " & $partTwo(elfPairs)
