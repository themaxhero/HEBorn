module Utils.Core exposing (swap, repeat)


swap : (a -> b -> c -> d) -> c -> b -> a -> d
swap function =
    (\a b c -> function c b a)


repeat : Int -> (a -> a) -> a -> a
repeat times func a =
    if times > 0 then
        repeat (times - 1) func (func a)
    else
        a
