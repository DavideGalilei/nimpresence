import os
import json
import times
import options
import strformat
import asyncdispatch

from ./nimpresence/types import OPCode
from ./nimpresence/utils import toUgly
from ./nimpresence/baseclient import BaseClient, initBaseClient, Pack, send

type
    Presence* = object
        client*: BaseClient
        clientId*: string
    
    Button* = object
        label*: string
        url*: string

proc initPresence*(clientId: string): Future[Presence] {.async.} =
    let client = await initBaseClient(clientId = clientId)

    result.client = client
    result.clientId = clientId

proc update*(
    self: Presence,
    state: Option[string] = none(string),
    details: Option[string] = none(string),
    partyId: Option[int] = none(int),
    partySize: Option[array[2, Positive]] = none(array[2, Positive]),
    join: Option[string] = none(string),
    spectate: Option[string] = none(string),
    match: Option[string] = none(string),
    buttons: Option[array[2, Button]] = none(array[2, Button]),
    largeImage: Option[string] = none(string),
    largeText: Option[string] = none(string),
    smallImage: Option[string] = none(string),
    smallText: Option[string] = none(string),
    start: Option[int] = none(int),
    `end`: Option[int] = none(int),
    pid: int = getCurrentProcessId(),
): Future[JsonNode] {.async.} =
    let payload = %* {
        "cmd": "SET_ACTIVITY",
        "args": %* {
            "pid": pid,
            "activity": %* {
                "instance": true,
            }
        },
        "nonce": %* "1637007106.87404775619506444939" # getTime().toUnixFloat()
    }

    if state.isSome():
        payload["args"]["activity"]["state"] = %* state.get()

    if details.isSome():
        payload["args"]["activity"]["details"] = %* details.get()

    if start.isSome():
        payload["args"]["activity"]["timestamps"]["start"] = %* start.get()
    
    if `end`.isSome():
        payload["args"]["activity"]["timestamps"]["end"] = %* `end`.get()
    
    if largeImage.isSome():
        payload["args"]["activity"]["assets"]["large_image"] = %* largeImage.get()

    if largeText.isSome():
        payload["args"]["activity"]["assets"]["large_text"] = %* largeText.get()

    if smallImage.isSome():
        payload["args"]["activity"]["assets"]["small_image"] = %* smallImage.get()

    if smallText.isSome():
        payload["args"]["activity"]["assets"]["small_text"] = %* smallText.get()

    if partyId.isSome():
        payload["args"]["activity"]["party"]["id"] = %* partyId.get()

    if partySize.isSome():
        payload["args"]["activity"]["party"]["size"] = %* partySize.get()

    if join.isSome():
        payload["args"]["activity"]["secrets"]["join"] = %* join.get()

    if spectate.isSome():
        payload["args"]["activity"]["secrets"]["spectate"] = %* spectate.get()

    if match.isSome():
        payload["args"]["activity"]["secrets"]["match"] = %* match.get()

    echo self.client.handshakeAnswer.answer
    echo payload
    let answer = await self.client.send(opcode = OPCode.FRAME, payload = toUgly(payload))


when isMainModule:
    proc main {.async.} =
        let presence = await initPresence(clientId = "909409932556767232")

        var i: int = 0
        while true:
            inc i
            discard await presence.update(
                state = some fmt"Chillin' #{i}",
                details = some r"`\(^~^)/`")
            await sleepAsync(15 * 1000) # Can update presence only each 15 seconds

    waitFor main()
