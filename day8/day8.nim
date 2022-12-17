import std/[sequtils, strutils, sugar]

type
  TreeMap = seq[seq[int]]

  Direction = enum
    left
    right
    up
    down


func parseMap(rawText: string): TreeMap =
  collect(newSeq):
    for ln in rawText.strip.splitLines:
      collect(newSeq):
        for c in ln:
          int(uint8(c) - uint8('0'))


iterator enumerateInterior[T](map: seq[T]): (int, T) =
  for p in zip(toSeq(1..len(map)-2), map[1..len(map)-2]):
    yield p


func partOne(map: TreeMap): int =
  let
    mapHeight = len(map)
    mapWidth = len(map[0])
  # Save iterations by counting the exterior
  # `-4` accounts for the corners that would be counted twice
  result += 2 * mapWidth + 2 * mapHeight - 4

  # My gut solution was T(n) = 4(n-1)^3 + 5 => O(n^3)... cringe!
  # (where n is the value used for the height and width of the map)
  # This makes my eyes bleed when factoring in the simplicity of what I'm doing.
  for (y, row) in enumerateInterior(map):
    for (x, col) in enumerateInterior(row):
      # We have four directions we can be visible from.
      var isVisible = [true, true, true, true]
      for tree_x in 0..x-1:
        if map[y][tree_x] >= col:
          isVisible[ord(left)] = false
          break
      for tree_x in x+1..mapWidth-1:
        if map[y][tree_x] >= col:
          isVisible[ord(right)] = false
          break
      for tree_y in 0..y-1:
        if map[tree_y][x] >= col:
          isVisible[ord(up)] = false
          break
      for tree_y in y+1..mapHeight-1:
        if map[tree_y][x] >= col:
          isVisible[ord(down)] = false
          break

      # Really just want the semantics of "any" in Haskell/Rust but Nim's
      # "any" accepts a predicate rather than folding with `or`
      if foldr(isVisible, a or b):
        result += 1


iterator revMapRange(upper: int): int =
  var x = upper - 1
  while x >= 0:
    yield x
    x -= 1


# If you weren't DFSing in part one you'd be stupid not to in part two.
func partTwo(map: TreeMap): int =
  let
    mapHeight = len(map)
    mapWidth = len(map[0])
  result = 0
  # We can once again ignore the perimeter since its scenic scores are always going to be zero.
  for (y, row) in enumerateInterior(map):
    for (x, col) in enumerateInterior(row):
      # Agh... very verbose considering the simplicity of the problem.
      # There has *got* to be a way to make this guy more terse. I repeat myself so much.
      var scenicScore = [0, 0, 0, 0]
      for tree_x in revMapRange(x):
        scenicScore[ord(left)] += 1
        if map[y][tree_x] >= col:
          break
      for tree_x in x+1..mapWidth-1:
        scenicScore[ord(right)] += 1
        if map[y][tree_x] >= col:
          break
      for tree_y in revMapRange(y):
        scenicScore[ord(up)] += 1
        if map[tree_y][x] >= col:
          break
      for tree_y in y+1..mapHeight-1:
        scenicScore[ord(down)] += 1
        if map[tree_y][x] >= col:
          break

      let maybeBest = foldr(scenicScore, a * b)
      if maybeBest > result:
        result = maybeBest


# const INPUT_FILE = "test_input"
const INPUT_FILE = "puzzle_input"

template assertEq(v1: untyped, v2: untyped): untyped =
  assert v1 == v2, "\nGot " & $v1 & " == " & $v2 & "!"

when isMainModule:
  let
    input = readFile(INPUT_FILE)
    treeMap = parseMap(input)
  when INPUT_FILE == "test_input":
    let
      p1 = partOne(treeMap)
      p2 = partTwo(treeMap)

    assertEq(p1, 21)
    assertEq(p2, 8)

    echo "Passed!"
  else:
    echo "Part One: " & $partOne(treeMap)
    echo "Part Two: " & $partTwo(treeMap)
