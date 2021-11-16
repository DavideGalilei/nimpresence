import options
import strformat
import asyncdispatch

import ../src/nimpresence

proc main {.async.} =
    let presence = await initPresence(clientId = "909409932556767232")

    var i: int = 0
    while true:
        inc i
        discard await presence.update(
            state = some fmt"Chillin' #{i}",
            details = some r"`\(^~^)/`")
        await sleepAsync(15 * 1000) # Can update presence only each 15 seconds

when isMainModule:
    waitFor main()
