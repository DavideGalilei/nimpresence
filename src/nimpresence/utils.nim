import os
import json
import distros
import endians
import strutils
import strformat

import ./exceptions

proc toLittleEndian*(data: uint32): array[0..3, byte] =
    var tempResult = cast[array[0..3, byte]](data)
    swapEndian32(addr result, addr tempResult[0])

proc toBigEndian*(data: string): uint32 =
    var tempResult = data[0..3]
    littleEndian32(addr result, addr tempResult[0])

proc toString*[T: byte | char | uint8](bytes: openarray[T]): string =
    # https://github.com/nim-lang/Nim/issues/14810#issue-645714028

    result = newString(bytes.len)
    copyMem(result[0].addr,
        bytes[0].unsafeAddr,
        bytes.len * sizeof(T)) # We don't actually need it, since sizeof(byte) is 1

template asBytes*(n: int32 | uint32): seq[byte] =
    @(cast[array[0..3, byte]](n))

proc toUgly*(node: JsonNode): string =
    toUgly(result, node)

proc getIpcPath*(pipe: string = ""): string =
    let
        isLinuxOrMacOs = detectOs(Linux) or detectOs(MacOSX)
        isWindows = detectOs(Windows)

    if not (isLinuxOrMacOs or isWindows):
        raise DiscordNotFound(msg: "Discord has not been found in this pc. Reason: unsupported platform")

    var ipc = "discord-ipc-"

    if pipe != "":
        ipc = fmt"{ipc}{pipe}"

    let tempdir = if isLinuxOrMacOs: getEnv("XDG_RUNTIME_DIR", getTempDir())
                else: r"\\?\pipe"
    let paths = if isLinuxOrMacOs: @[".", "snap.discord", "app/com.discordapp.Discord"]
                else: @["."]

    for path in paths:
        let fullPath = absolutePath(tempdir / path)

        if isWindows or dirExists(fullPath):
            for entry in walkDir(fullPath):
                if splitPath(entry.path)[1].startswith(ipc):
                    return entry.path

    raise DiscordNotFound(msg: "Discord has not been found in this pc. Reason: path not found")

when isMainModule:
    echo "--- Utils Informations ---"
    echo fmt"InterProcess Communication path: {getIpcPath()}"

    let converted = toBigEndian("\x01\x00\x00\x00")
    echo fmt"""b'\\x01\\x00\\x00\\x00' from little to big: {converted}"""
