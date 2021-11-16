import net
import json
import distros
import asyncnet
import strformat
import asyncfile
import asyncdispatch

from ./types import OPCode
from ./exceptions import DiscordErrorCode
from ./utils import getIpcPath, toLittleEndian, toBigEndian, toString, asBytes, toUgly

type
    BaseClient* = object
        ipc*: string
        clientId*: string
        handshakeAnswer*: Pack

        case isWindows: bool
        of true:
            pipe*: AsyncFile
        else:
            socket*: AsyncSocket

    Pack* = object
        code*: OPCode
        length*: int
        answer*: JsonNode

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
proc close*(self: BaseClient): Future[void] {.async.}
proc open*(self: BaseClient): Future[BaseClient] {.async.}


proc send*(
    client: BaseClient,
    opcode: OPCode,
    payload: string,
): Future[Pack] {.async.} =
    template checkParsed(parsed: JsonNode) =
        if "code" in parsed:
            raise DiscordErrorCode(
                msg: fmt"""[CODE {parsed["code"].getInt()}] {parsed["message"].getStr()}""",
                code: parsed["code"].getInt(),
                message: parsed["message"].getStr()
            )

    var
        parsed: JsonNode
        code: int
        length: int
        answer: string

    var sendPayload: seq[byte] = @[]

    sendPayload &= asBytes(opcode.uint32) & asBytes(payload.len.uint32)
    sendPayload &= cast[seq[byte]](payload)

    if client.isWindows:
        await client.pipe.write(toString(sendPayload))

        let firstBytes = await client.pipe.read(4)
        doAssert firstBytes.len != 0, "Discord sent no bytes"
        
        code = toBigEndian(firstBytes).int
        length = toBigEndian(await client.pipe.read(4)).int
        answer = await client.pipe.read(length.int)

        parsed = parseJson(answer)
        checkParsed(parsed)
    else:
        await client.socket.send(toString(sendPayload))

        let firstBytes = await client.socket.recv(4)
        doAssert firstBytes.len != 0, "Discord sent no bytes"
        
        code = toBigEndian(firstBytes).int
        length = toBigEndian(await client.socket.recv(4)).int
        answer = await client.socket.recv(length.int)

        parsed = parseJson(answer)
        checkParsed(parsed)

    return Pack(code: OPCode(code), length: length, answer: parsed)

proc initBaseClient*(
    clientId: string,
    ipcPath: string = "",
    pipe: string = "",
): Future[BaseClient] {.async.} =
    let isWindows = detectOs(Windows)
    result = BaseClient(isWindows: isWindows)

    result.ipc = if ipcPath != "": ipcPath
            else: getIpcPath(pipe = pipe)

    result.clientId = clientId
    
    result = await result.open()
    result.handshakeAnswer = await result.handshake()

proc open*(self: BaseClient): Future[BaseClient] {.async.} =
    result = self
    if result.isWindows:
        result.pipe = openAsync(self.ipc, fmReadWriteExisting)
    else:
        result.socket = newAsyncSocket(AF_UNIX, SOCK_STREAM, IPPROTO_IP)


proc handshake*(self: BaseClient): Future[Pack] {.async.} =
    let initPayload = %* {"v": 1, "client_id": self.clientId}

    when not defined(windows):
        await self.socket.connectUnix(self.ipc)

    let pack = await self.send(
        opcode = OPCode.HANDSHAKE,
        payload = toUgly(initPayload)
    )

    return pack


proc close*(self: BaseClient): Future[void] {.async.} =
    when defined(windows):
        self.pipe.close()
    else:
        self.socket.close()


when isMainModule:
    proc main {.async.} =
        var client = await initBaseClient("123456789")

    waitFor main()
