import os
import json
import times
import options
import asyncdispatch

from ./nimpresence/types import OPCode
from ./nimpresence/utils import toUgly
from ./nimpresence/baseclient import BaseClient, initBaseClient, Pack, send, close, open, handshake

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
    partySize: Option[array[0..1, int]] = none(array[0..1, int]),
    join: Option[string] = none(string),
    spectate: Option[string] = none(string),
    match: Option[string] = none(string),
    buttons: Option[seq[Button]] = none(seq[Button]),
    largeImage: Option[string] = none(string),
    largeText: Option[string] = none(string),
    smallImage: Option[string] = none(string),
    smallText: Option[string] = none(string),
    start: Option[int64] = none(int64),
    `end`: Option[int64] = none(int64),
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
        "nonce": %* getTime().toUnixFloat()
    }

    if state.isSome():
        payload["args"]["activity"]["state"] = %* state.get()

    if details.isSome():
        payload["args"]["activity"]["details"] = %* details.get()

    if start.isSome() or `end`.isSome():
        payload["args"]["activity"]["timestamps"] = %* {}

        if start.isSome():
            payload["args"]["activity"]["timestamps"]["start"] = %* start.get()
        
        if `end`.isSome():
            payload["args"]["activity"]["timestamps"]["end"] = %* `end`.get()
    
    if largeImage.isSome() or largeText.isSome() or smallImage.isSome() or smallText.isSome():
        payload["args"]["activity"]["assets"] = %* {}

        if largeImage.isSome():
            payload["args"]["activity"]["assets"]["large_image"] = %* largeImage.get()

        if largeText.isSome():
            payload["args"]["activity"]["assets"]["large_text"] = %* largeText.get()

        if smallImage.isSome():
            payload["args"]["activity"]["assets"]["small_image"] = %* smallImage.get()

        if smallText.isSome():
            payload["args"]["activity"]["assets"]["small_text"] = %* smallText.get()

    if partyId.isSome() or partySize.isSome():
        payload["args"]["activity"]["party"] = %* {}

        if partyId.isSome():
            payload["args"]["activity"]["party"]["id"] = %* partyId.get()

        if partySize.isSome():
            payload["args"]["activity"]["party"]["size"] = %* partySize.get()

    if join.isSome() or spectate.isSome() or match.isSome():
        payload["args"]["activity"]["secrets"] = %* {}

        if join.isSome():
            payload["args"]["activity"]["secrets"]["join"] = %* join.get()

        if spectate.isSome():
            payload["args"]["activity"]["secrets"]["spectate"] = %* spectate.get()

        if match.isSome():
            payload["args"]["activity"]["secrets"]["match"] = %* match.get()
    
    if buttons.isSome():
        payload["args"]["activity"]["buttons"] = %* buttons.get()

    let answer = await self.client.send(opcode = OPCode.FRAME, payload = toUgly(payload))
    return answer.answer


proc stop*(presence: Presence): Future[void] {.async.} =
    await presence.client.close()


proc reopen*(presence: Presence): Future[Presence] {.async.} =
    result = Presence(
        clientId: presence.clientId,
        client: await presence.client.open(),
    )
    discard await result.client.handshake()


when isMainModule:
    import random, strformat
    
    proc main {.async.} =
        var presence = await initPresence(clientId = "909409932556767232")

        var i: int = 0
        while true:
            randomize()
            inc i
            echo await presence.update(
                state = some fmt"Test #{i}",
                details = some r"`\(^~^)/`",
                # join = some $(rand(10000)),
                # match = some $(rand(10000)),
                # spectate = some $(rand(10000)),
                # partyId = some rand(10000),
                # partySize = some [i, 100000],
                # largeText = some ">>",
                # largeImage = some "bird512",
                `end` = some getTime().toUnix() + 1000,
                buttons = some @[
                    Button(label: "aaaaa", url: "https://google.com"),
                    Button(label: "aaaaa", url: "https://google.com")
                ],
            )
            await sleepAsync(15 * 1000) # https://discord.com/developers/docs/game-sdk/activities#updateactivity

    waitFor main()
