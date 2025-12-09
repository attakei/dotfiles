import std/[algorithm, files, json, options, parseopt, paths, sequtils, sets, strutils]

type Argument = object
  src: Option[Path]
  dest: Option[Path]
  excludes: seq[string]

proc parseArgument(cmdline: string = ""): Argument =
  result = Argument(src: none(Path), dest: none(Path), excludes: @[])
  var p = initOptParser(cmdline)
  while true:
    p.next()
    case p.kind
    of cmdEnd:
      break
    of cmdShortOption, cmdLongOption:
      case p.key
      of "exclude":
        result.excludes = p.val.split(",")
      else:
        raise newException(ValueError, "Invalid option: " & p.key)
    of cmdArgument:
      let path = Path(p.key).expandTilde.absolutePath
      if not path.fileExists:
        raise newException(ValueError, "File not found: " & $path)
      if result.src.isNone:
        result.src = some(path)
      elif result.dest.isNone:
        result.dest = some(path)
      else:
        raise newException(ValueError, "All paths are already specified")

proc mergeSettings(src: JsonNode, dest: JsonNode, excludes: seq[string]): JsonNode =
  result = parseJson("{}")
  let excludeSet = excludes.sorted
  let srcKeys = src.keys.toSeq.sorted
  let destKeys = dest.keys.toSeq.sorted
  # Keep excluded keys
  for key in excludes.filterIt(it in dest):
    result[key] = dest[key]
  # Pick keys from src
  for key in srcKeys:
    if key in destKeys or key in excludes:
      continue
    result[key] = src[key]
  # Pick keys from dest
  for key in destKeys:
    if key in srcKeys or key in excludeSet:
      continue
    result[key] = dest[key]
  # Merge keys
  for key in srcKeys:
    if key notin destKeys or key in excludeSet:
      continue
    if dest[key].kind == JArray:
      result[key] = newJArray()
      for val in (src[key].elems.toHashSet + dest[key].elems.toHashSet):
        result[key].elems.add(val)
    elif dest[key].kind == JObject:
      result[key] = newJObject()
      for skey, val in mergeSettings(src[key], dest[key], @[]):
        result[key][skey] = val
    else:
      result[key] = src[key]

when isMainModule:
  try:
    let args = parseArgument()
    let src = parseFile($args.src.get())
    let dest = parseFile($args.dest.get())
    let merged = mergeSettings(src, dest, args.excludes)
    writeFile($args.dest.get(), merged.pretty())
  except ValueError as e:
    echo("Error:", e.msg)
