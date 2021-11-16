<p align="center">
    <a href="https://github.com/DavideGalilei/nimpresence">
        <img src="/assets/banner.png" alt="nimpresence banner" />
    </a>
    <br>
    <b>A simple to use async Nim library which aims to use Discord's rich presence API with ease</b>
</p>

# NimPresence

<a href="https://img.shields.io/badge/Made%20with-Nim-yellow?style=for-the-badge&logo=Nim" alt="Made with Nim"></a>

## Features
 - It's async
 - Works on both Unix and Windows
 - Has no external dependencies
 - It's easy to use (check [examples](/examples) folder)

## Installation
```bash
$ nimble install https://github.com/DavideGalilei/nimpresence
```

## How to get Client ID?
Go to https://discord.com/developers/applications, authenticate, create an application, and get its client id. I will leave mine in the examples to make them reproducible.

## Usage

```nim
discard await presence.update(
    state = some "Hello world!",
    details = some r"`\(^~^)/`"
    `end` = some getTime().toUnix() + 1000,
    buttons = some @[
        Button(label: "aaaaa", url: "https://google.com"),
        Button(label: "aaaaa", url: "https://google.com")
    ]
)
```

<img src="/assets/example.jpg"></img>

> ⚠️ **If the library is not working**
 - Mixing parameters such as match/spectate/join with buttons is not permitted, and will not update your presence (try with different options)
 - If you make too much requests in a short while, discord may ratelimit you for some minutes, try again later
 - If it gives compile errors, remember that you need to use the `some` function from `std/options` library, since optional parameters are used in `Presence.update(...)`

## Credits
Special thanks to [pypresence](https://github.com/qwertyquerty/pypresence), which let me understand how Discord's socket works.

## License
This project is under MIT license.
