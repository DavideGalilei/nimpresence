import options
import asyncdispatch

import ../src/nimpresence

proc main {.async.} =
    var presence = await initPresence(clientId = "909409932556767232")

    discard await presence.update(
        state = some "Chillin'",
        details = some r"`\(^~^)/`")
    
    await sleepAsync(10 * 1000)
    # Hide the presence after 10 seconds
    await presence.stop()

    await sleepAsync(5 * 1000)
    # Sleep 5 seconds until program terminates
    # and rich presence is cleared automatically
    # by discord itself (it's checked by program's pid)

when isMainModule:
    waitFor main()
