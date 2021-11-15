## Data models defined in https://discord.com/developers/docs/game-sdk/activities#data-models

type OPCode* = enum
    HANDSHAKE = 0
    FRAME = 1
    CLOSE = 2
    PING = 3
    PONG = 4


type
    User* = object
        id*: int64             ## The user's id
        username*: string      ## Their name
        discriminator*: string ## The user's unique discrim
        avatar*: string        ## The hash of the user's avatar
        bot*: bool             ## If the user is a bot user

    Activity* = object
        applicationId*: int64   ## Your application id - this is a read-only field
        name*: string           ## Name of the application - this is a read-only field
        state*: string          ## The player's current party status
        details*: string        ## What the player is currently doing
        timestamps*: ActivityTimestamps ## Helps create elapsed/remaining timestamps on a player's profile
        assets*: ActivityAssets ## Assets to display on the player's profile
        party*: ActivityParty   ## Information about the player's party
        secrets*: ActivitySecrets ## Secret passwords for joining and spectating the player's game
        instance*: bool         ## Whether this activity is an instanced context, like a match

    ActivityTimestamps* = object ## Activity Timestamps. Docs: https://discord.com/developers/docs/topics/gateway#activity-object-activity-timestamps
        start*: int64 ## Unix timestamp - send this to have an "elapsed" timer
        `end`*: int64 ## Unix timestamp - send this to have a "remaining" timer

    ActivityAssets* = object ## Activity Assets. Docs: https://discord.com/developers/docs/topics/gateway#activity-object-activity-assets
        largeImage*: string ## Keyname of an asset to display
        largeText*: string  ## Hover text for the large image
        smallImage*: string ## Keyname of an asset to display
        smallText*: string  ## Hover text for the small image

    ActivityParty* = object ## Activity Party. Docs: https://discord.com/developers/docs/topics/gateway#activity-object-activity-party
        id*: string      ## A unique identifier for this party
        size*: PartySize ## Info about the size of the party

    PartySize* = object
        currentSize*: int32 ## The current size of the party
        maxSize*: int32     ## The max possible size of the party

    ActivitySecrets* = object
        match*: string    ## Unique hash for the given match context
        join*: string     ## Unique hash for chat invites and Ask to Join
        spectate*: string ## Unique hash for Spectate button

    ActivityType* = enum ## For more details about the activity types, see Gateway documentation: https://discord.com/developers/docs/topics/gateway#activity-object-activity-types
        playing = 0 ## Game - Playing {name}. Example: "Playing Rocket League"
        streaming = 1 ## Streaming - Streaming {details}. Example: "Streaming Rocket League"
                    ## The streaming type currently only supports Twitch and YouTube.
                    ## Only https://twitch.tv/ and https://youtube.com/ urls will work.

        listening = 2 ## Listening - Listening to {name}. Example: "Listening to Spotify"
        watching = 3 ## Watching - Watching {name}. Example: "Watching YouTube Together"
        custom = 4  ## Custom - {emoji} {name}. Example: ":smiley: I am cool"
        competing = 5 ## Competing - Competing in {name}. Example: "Competing in Arena World Champions"

    ## ActivityType is strictly for the purpose of handling events that you receive from Discord;
    ## though the SDK/our API will not reject a payload with an ActivityType sent,
    ## it will be discarded and will not change anything in the client.

    ActivityJoinRequestReply* = enum
        no = 0
        yes = 1
        ignore = 2

    ActivityActionType* = enum
        join = 1
        spectate = 2
