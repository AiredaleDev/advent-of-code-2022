import std/sequtils

iterator subseqs(s: string, plen: int): (string, int) =
  var lo = 0
  while lo + plen - 1 < len(s):
    yield (s[lo..(lo+plen-1)], lo+plen)
    lo += 1


proc countPrePadding(stream: string, plen: int): int =
  for (maybePacket, hiPlusOne) in subseqs(stream, plen):
    let noDups = deduplicate(maybePacket)
    if len(noDups) == plen:
       return hiPlusOne


const file = "puzzle_input"
# const file = "test_input"

when isMainModule:
  let input = readFile(file)
  echo "Part One: " & $countPrePadding(input, 4)
  echo "Part Two: " & $countPrePadding(input, 14)
  when file == "test_input":
    assert countPrePadding(input, 4) == 7
