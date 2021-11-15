type
    DiscordError* = ref object of CatchableError

    DiscordNotFound* = ref object of DiscordError
    DiscordErrorCode* = ref object of DiscordError ## Discord sent an error code: 
        code*: int
        message*: string
