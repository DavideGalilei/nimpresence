import net
import json
import asyncnet
import strformat
import asyncdispatch

from ./types import OPCode
from ./exceptions import DiscordErrorCode
from ./utils import getIpcPath, toLittleEndian, toBigEndian, toString, asBytes

type
    BaseClient* = object
        ipc*: string
        clientId*: string
        socket*: AsyncSocket
        handshakeAnswer*: Pack

    Pack* = object
        code*: OPCode
        length*: int
        answer*: string
#[
    Buffer = object
        data: string
        pos: int

template read(buffer: Buffer, size: Positive): string =
    buffer.pos = (buffer.pos + size) mod buffer.data.len()
    return buffer.data[buffer.pos .. min(buffer.pos + size, buffer.data.len())]
]#

#[proc send(
    client: BaseClient,
    data: openarray[uint8 | byte | char]
): Future[int] {.async.} =
    await client.socket.send(toString(data))]#

# Forward function declaration
proc handshake*(self: BaseClient): Future[Pack] {.async.}
proc send*(client: BaseClient, opcode: OPCode, payload: string): Future[Pack] {.async.}
proc initBaseClient*(clientId: string, ipcPath: string = "", pipe: string = ""): Future[BaseClient] {.async.}


proc send*(
    client: BaseClient,
    opcode: OPCode,
    payload: string,
): Future[Pack] {.async.} =
    var sendPayload: seq[byte] = @[]

    sendPayload &= asBytes(opcode.uint32) & asBytes(payload.len.uint32)
    sendPayload &= cast[seq[byte]](payload)

    await client.socket.send(toString(sendPayload))

    let firstBytes = await client.socket.recv(4)
    doAssert firstBytes.len != 0, "Discord sent no bytes"
    
    let
        code = toBigEndian(firstBytes).int
        length = toBigEndian(await client.socket.recv(4)).int
        answer = await client.socket.recv(length.int)

    let p = parseJson(answer)
    if "code" in p:
        raise DiscordErrorCode(
            msg: fmt"""[CODE {p["code"].getInt()}] {p["message"].getStr()}""",
            code: p["code"].getInt(),
            message: p["message"].getStr()
        )

    return Pack(code: OPCode(code), length: length, answer: answer)

proc initBaseClient*(
    clientId: string,
    ipcPath: string = "",
    pipe: string = "",
): Future[BaseClient] {.async.} =
    result.ipc = if ipcPath != "": ipcPath
            else: getIpcPath(pipe = pipe)

    result.socket = newAsyncSocket(AF_UNIX, SOCK_STREAM, IPPROTO_IP)
    result.clientId = clientId

    result.handshakeAnswer = await result.handshake()

proc handshake*(self: BaseClient): Future[Pack] {.async.} =
    let initPayload = """{"v": 1, "client_id": """" & self.clientId & "\"}"

    await self.socket.connectUnix(self.ipc)

    let pack = await self.send(
        opcode = OPCode.HANDSHAKE,
        payload = initPayload
    )

    return pack


when isMainModule:
    proc main {.async.} =
        let client = await initBaseClient("123456789")
        echo 123

    waitFor main()
