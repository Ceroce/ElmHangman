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

type alias Game = 
    { wordToGuess : String
    , lettersTried : List String
    , attempts : Int
    }

type Model = 
    Starting
    | Playing String

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
            ( Playing (wordOrDefault maybeWord)
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
            [ inDiv "Welcome to Hangman"
            , button [ onClick Generate ] [ text "Start" ]
            ]
            
        Playing word ->
            div [] ( lettersOf word |> map inDiv )
            

inDiv : String -> Html Msg
inDiv str =
   div [] [ text str ]


lettersOf : String -> List String
lettersOf str =
    recLettersOf str []

recLettersOf : String -> List String -> List String
recLettersOf str acc =
    if String.isEmpty str then acc 
    else recLettersOf (String.dropLeft 1 str) (acc ++ [String.left 1 str])
        