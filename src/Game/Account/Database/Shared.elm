module Game.Account.Database.Shared exposing (..)


type CollectWithBankError
    = CollectUSDBadRequest
    | UnkownCollectError


type InstallError
    = InstallBadRequest
    | InstallAlreadyInstalled
    | InstallSelf
    | InstallFileIsNotInstallable
    | InstallUnknown
