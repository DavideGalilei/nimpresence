import options
import strformat
import asyncdispatch

import ../src/nimpresence

proc main {.async.} =
    let presence = await initPresence(clientId = "909409932556767232")

    discard await presence.update(
        state = some "Hello",
        details = some "World!",
        buttons = some @[
            Button(label: "Button 1", url: "https://nim-lang.org"),
            Button(label: "Button 2", url: "https://github.com")
        ]
    )
    
    while true:
        await sleepAsync(15 * 1000)

when isMainModule:
    waitFor main()
