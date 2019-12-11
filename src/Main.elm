module Main exposing (main)
import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)

import List as List
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
            ( Playing (wordOrDefault maybeWord |> String.toUpper)
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
    Element.layout [] <| 
    case model of
        Starting -> startingScreen
        Playing word -> playingScreen word


startingScreen : Element Msg
startingScreen =
    Element.column []
        [ text "Welcome to Hangman"
        , Input.button 
            [ Background.color (rgb 0.4 0.6 1.0)
            , padding 5
            ] 
                {onPress = Just Generate, label = text "Start" }
        ]

playingScreen : String -> Element Msg
playingScreen word =
    Element.row 
        [ spacing 4 ] 
        ( lettersOf word |> List.map letterView )

lettersOf : String -> List String
lettersOf str =
    recLettersOf str []

recLettersOf : String -> List String -> List String
recLettersOf str acc =
    if String.isEmpty str then acc 
    else recLettersOf (String.dropLeft 1 str) (acc ++ [String.left 1 str])

letterView : String -> Element Msg
letterView letter = 
    Element.el 
        [ width (px 76)
        , height (px 84)
        , Font.size 64
        , Font.family 
            [ Font.typeface "Giorgia"
            , Font.serif 
            ]
        , Font.center
        , Font.color (rgb 0.45 0.35 0.25)
        , Background.color (rgb 0.9 0.7 0.5)
        , Border.rounded 6
        , Border.color (rgb 0.45 0.35 0.25)
        , Border.width 2
        , padding 5
        ] 
        (text letter)
        