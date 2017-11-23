module Game.Meta.Network exposing (..)


type alias IP =
    String


type alias ID =
    String


type alias NIP =
    ( ID, IP )


toNip : ID -> IP -> NIP
toNip =
    (,)


getId : NIP -> ID
getId =
    Tuple.first


getIp : NIP -> IP
getIp =
    Tuple.second


toString : NIP -> String
toString ( id, ip ) =
    id ++ "," ++ ip


fromString : String -> NIP
fromString str =
    case String.split "," str of
        [ id, ip ] ->
            ( id, ip )

        _ ->
            ( "::", "" )


isFromInternet : NIP -> Bool
isFromInternet ( id, _ ) =
    id == "::"


filterInternet : List NIP -> List NIP
filterInternet list =
    List.filter isFromInternet list
