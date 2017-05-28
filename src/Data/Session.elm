module Data.Session exposing (Session, attempt)

import Data.User as User exposing (User)
import Data.AuthToken exposing (AuthToken)
import Util exposing ((=>))
import Bootstrap.Navbar


type alias Session =
    { user : Maybe User
    , navbarState : Bootstrap.Navbar.State
    }


attempt : String -> (AuthToken -> Cmd msg) -> Session -> ( List String, Cmd msg )
attempt attemptedAction toCmd session =
    case Maybe.map .token session.user of
        Nothing ->
            [ "You have been signed out. Please sign back in to " ++ attemptedAction ++ "." ] => Cmd.none

        Just token ->
            [] => toCmd token
