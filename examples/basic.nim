import options
import asyncdispatch

import ../src/nimpresence

proc main {.async.} =
    let presence = await initPresence(clientId = "909409932556767232")

    discard await presence.update(
        state = some "Chillin'",
        details = some r"`\(^~^)/`")
    
    while true:
        await sleepAsync(15 * 1000)
        # Keeps the program alive

when isMainModule:
    waitFor main()
