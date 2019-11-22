module Main exposing (main)
import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import List exposing (map)

-- MAIN

main = 
    Browser.sandbox {
        init = init,
        update = update,
        view = view
    }

-- MODEL

type alias Model = 
    List String

init : Model
init = 
    words


words : List String
words = 
    ["absolute", "behemoth", "cardinal", "destructive", "escape", "follow", "generate", "horny", "idiomatic", "jellyfish", "kettle", "species", "regretable", "trouser", "wisdom"]


-- UPDATE

type Msg = Show

update : Msg -> Model -> Model
update msg model =
    case msg of 
        Show ->
            model


-- VIEW

view : Model -> Html Msg
view model =
    div [] 
        (map stringInDiv model)

stringInDiv : String -> Html Msg
stringInDiv str =
   div [] [ text str ]