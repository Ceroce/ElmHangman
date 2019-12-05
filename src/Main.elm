module Main exposing (main)
import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import List exposing (map)
import Random
import Random.List

-- MAIN

main = 
    Browser.element {
        init = init
    ,   update = update
    ,   subscriptions = subscriptions
    ,   view = view
    }

-- MODEL

type Model = 
    Starting
    | Guessing String

init : () -> ( Model, Cmd Msg )
init _ = 
    ( Starting
    , Cmd.none
    )


words : List String
words = 
    ["absolute", "behemoth", "cardinal", "destructive", "escape", "follow", "generate", "horny", "idiomatic", "jellyfish", "kettle", "species", "regretable", "trouser", "wisdom"]

-- UPDATE

type Msg = 
    Generate 
    | Guess (Maybe String, List String)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of 
        Generate ->
            (model
            , Random.generate Guess (Random.List.choose words)
            )

        Guess (maybeWord, _) ->
            ( Guessing (wordOrDefault maybeWord)
            , Cmd.none
            )

wordOrDefault : Maybe String -> String
wordOrDefault maybeWord = 
    case maybeWord of 
        Just word ->
            word
        Nothing ->
            "D-Fault"

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

-- VIEW

view : Model -> Html Msg
view model =
    case model of
        Starting ->
            div [] 
            [ stringInDiv "Welcome to Hangman"
            , button [ onClick Generate ] [ text "Start" ]
            ]
            

        Guessing word ->
            stringInDiv word

stringInDiv : String -> Html Msg
stringInDiv str =
   div [] [ text str ]