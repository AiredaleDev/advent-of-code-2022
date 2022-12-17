import std/[sequtils, strutils, tables]

type
  FSKind = enum
    fsDir
    fsFile
  FSNode = ref object
    case kind: FSKind
    of fsDir:
      files: Table[string, FSNode]
    of fsFile:
      fileSize: int


template top(stack: untyped): untyped =
  stack[len(stack)-1]


func constructFileTree(commands: seq[string]): FSNode =
  result = FSNode(kind: fsDir, files: initTable[string, FSNode]())
  let commands = commands[1..len(commands)-1] # We manually add root as a special case.
  var callStack = @[result]
  for cmd in commands:
    let tokens = cmd.splitWhitespace
    case tokens[0]
    of "$":
      if tokens[1] == "cd":
        if tokens[2] != "..":
          callStack.add(top(callStack).files[tokens[2]])
        else:
          discard callStack.pop
    of "dir":
      top(callStack).files[tokens[1]] = FSNode(kind: fsDir, files: initTable[string, FSNode]())
    else:
      top(callStack).files[tokens[1]] = FSNode(kind: fsFile, fileSize: parseInt(tokens[0]))


# For debugging purposes.
proc printTree(tree: FSNode): void =
  proc printTreeHelper(tree: FSNode, indent: int): void =
    let padding = repeat(" ", indent)
    for (filename, file) in tree.files.pairs:
      case file.kind
      of fsFile:
        echo padding & filename & ": " & $file.fileSize
      of fsDir:
        echo padding & filename & " {"
        printTreeHelper(file, indent + 2)
        echo padding & "}"

  echo "/ {"
  printTreeHelper(tree, 2)
  echo "}"


# Basically, you want to first find the sizes of all directories. "Double-counting" (e.g. dir e has size 10
# and dir f including e and all its other files has size 20, therefore the sum is 30) is denoted as acceptable
# by the problem.
func getDirSizes(tree: FSNode, sizes: var seq[int]): void =
  assert tree.kind == fsDir, "We only care about directories!"
  var thisDirsSize = 0
  for file in tree.files.values:
    case file.kind
    of fsFile:
      thisDirsSize += file.fileSize
    of fsDir:
      getDirSizes(file, sizes)
      thisDirsSize += top(sizes)
  sizes.add(thisDirsSize)


# Sum up the sizes of all directories whose contents are smaller than 100K
func partOne(tree: FSNode): int =
  var dirSizes: seq[int] = @[]
  getDirSizes(tree, dirSizes)
  # This is a lambda-brained way of filtering out any directory that's larger than 100K
  # and summing up their sizes. All sizes |-> All sizes <= 100K |-> Sum of all sizes <= 100K
  return foldr(dirSizes.filter(func(s: int): bool = s <= 100000), a + b)


# Find the size of the smallest directory whose deletion would free up enough space to update the machine.
# (The disk is 70000000 blocks big, We need 30000000 blocks available)
func partTwo(tree: FSNode): int =
  const
    DISK_SIZE = 70000000
    TARGET_SPACE_CONSUMED = DISK_SIZE - 30000000
  result = DISK_SIZE
  var dirSizes: seq[int] = @[]
  getDirSizes(tree, dirSizes)

  # Root (added last) is the largest and describes the whole FS.
  let currentSpaceConsumed = top(dirSizes)
  for dirSize in dirSizes:
    if currentSpaceConsumed - dirSize <= TARGET_SPACE_CONSUMED and dirSize < result:
      result = dirSize


# const INPUT_FILE = "test_input"
const INPUT_FILE = "puzzle_input"

when isMainModule:
  let
    input = readFile(INPUT_FILE)
    fileTree = constructFileTree(input.strip.splitLines)
  # printTree(fileTree)
  echo "Part One: " & $partOne(fileTree)
  echo "Part Two: " & $partTwo(fileTree)
