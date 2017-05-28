module Views.Page exposing (frame, ActivePage(..), bodyId, Msg(..))

{-| The frame around a typical page - that is, the header and footer.
-}

import Route exposing (Route)
import Route exposing (Route)
import Html exposing (..)
import Html.Attributes exposing (..)
import Route exposing (Route)
import Data.User as User exposing (User, Username)
import Data.UserPhoto as UserPhoto exposing (UserPhoto)
import Data.Session as Session exposing (Session)
import Html
import Html.Lazy exposing (lazy2)
import Views.Spinner exposing (spinner)
import Util exposing ((=>))
import Bootstrap.Navbar as Navbar


{-| Determines which navbar link (if any) will be rendered as active.

Note that we don't enumerate every page here, because the navbar doesn't
have links for every page. Anything that's not part of the navbar falls
under Other.

-}
type ActivePage
    = Other
    | Home
    | Login
    | Register
    | Settings
    | Profile Username
    | NewArticle


{-| A page can return either an message directed to the subpage content or to the global navbar
-}
type Msg contentMsg navMsg
    = Content contentMsg
    | Navbar navMsg


{-| Take a page's Html and frame it with a header and footer.

The caller provides the current user, so we can display in either
"signed in" (rendering username) or "signed out" mode.

isLoading is for determining whether we should show a loading spinner
in the header. (This comes up during slow page transitions.)

-}
frame : Session -> (Navbar.State -> navMsg) -> Bool -> ActivePage -> Html contentMsg -> Html (Msg contentMsg navMsg)
frame session navTagger isLoading page content =
    div [ class "page-frame" ]
        [ Html.map Navbar (navbarTop session navTagger)
        , Html.map Content content
        , Html.map Content viewFooter
        ]


navbarTop : Session -> (Navbar.State -> msg) -> Html msg
navbarTop session tagger =
    Navbar.config tagger
        |> Navbar.brand [ href "#" ] [ text "My Brand!" ]
        |> Navbar.view session.navbarState


viewHeader : ActivePage -> Maybe User -> Bool -> Html msg
viewHeader page user isLoading =
    nav [ class "navbar navbar-light" ]
        [ div [ class "container" ]
            [ a [ class "navbar-brand", Route.href Route.Home ]
                [ text "conduit" ]
            , ul [ class "nav navbar-nav pull-xs-right" ] <|
                lazy2 Util.viewIf isLoading spinner
                    :: (navbarLink (page == Home) Route.Home [ text "Home" ])
                    :: viewSignIn page user
            ]
        ]


viewSignIn : ActivePage -> Maybe User -> List (Html msg)
viewSignIn page user =
    case user of
        Nothing ->
            [ navbarLink (page == Login) Route.Login [ text "Sign in" ]
            , navbarLink (page == Register) Route.Register [ text "Sign up" ]
            ]

        Just user ->
            [ navbarLink (page == NewArticle) Route.NewArticle [ i [ class "ion-compose" ] [], text " New Post" ]
            , navbarLink (page == Settings) Route.Settings [ i [ class "ion-gear-a" ] [], text " Settings" ]
            , navbarLink
                (page == Profile user.username)
                (Route.Profile user.username)
                [ img [ class "user-pic", UserPhoto.src user.image ] []
                , User.usernameToHtml user.username
                ]
            , navbarLink False Route.Logout [ text "Sign out" ]
            ]


viewFooter : Html msg
viewFooter =
    footer []
        [ div [ class "container" ]
            [ a [ class "logo-font", href "/" ] [ text "conduit" ]
            , span [ class "attribution" ]
                [ text "An interactive learning project from "
                , a [ href "https://thinkster.io" ] [ text "Thinkster" ]
                , text ". Code & design licensed under MIT."
                ]
            ]
        ]


navbarLink : Bool -> Route -> List (Html msg) -> Html msg
navbarLink isActive route linkContent =
    li [ classList [ ( "nav-item", True ), ( "active", isActive ) ] ]
        [ a [ class "nav-link", Route.href route ] linkContent ]


{-| This id comes from index.html.

The Feed uses it to scroll to the top of the page (by ID) when switching pages
in the pagination sense.

-}
bodyId : String
bodyId =
    "page-body"
