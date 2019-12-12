module Main exposing (..)
import Browser
import Debug exposing (..)
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
type LetterBox =
    Found String
    | Unknown

type alias Game = 
    { wordToGuess : String
    , lettersTried : List String
    , letterBoxes : List LetterBox
    , attempts : Int
    }

type Model = 
    Starting
    | Playing Game

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
    | Typed String

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of 
        Generate ->
            (model
            , Random.generate Guess (Random.List.choose words)
            )

        Guess (maybeWord, _) ->
            let 
                word = 
                    wordOrDefault maybeWord |> String.toUpper

                game =
                    { wordToGuess = word
                    , lettersTried = []
                    , letterBoxes = determineLetterBoxes [] word
                    , attempts = 0
                    }

            in
                ( Playing game
                , Cmd.none
                )

        Typed text ->
            case model of
                Playing game -> 
                    let letter = String.right 1 text |> String.toUpper
                        lettersTried = game.lettersTried ++ [letter]
                        theLog = log "lettersTried" lettersTried
                    in
                        ( Playing 
                            { game | lettersTried = lettersTried
                            , letterBoxes = determineLetterBoxes lettersTried game.wordToGuess
                            , attempts = game.attempts + 1 }
                        , Cmd.none
                        )
                
                _ -> (model, Cmd.none)
        

wordOrDefault : Maybe String -> String
wordOrDefault maybeWord = 
    case maybeWord of 
        Just word ->
            word
        Nothing ->
            "D-Fault"

determineLetterBoxes : List String -> String -> List LetterBox
determineLetterBoxes lettersTried wordToGuess =
    let wordLetters = lettersOf wordToGuess
    in
        List.map (determineLetterBox lettersTried) wordLetters 

determineLetterBox : List String -> String ->  LetterBox
determineLetterBox lettersTried letter  =
    if List.member letter lettersTried then
        Found letter
    else
        Unknown

lettersOf : String -> List String
lettersOf str =
    recLettersOf str []

recLettersOf : String -> List String -> List String
recLettersOf str acc =
    if String.isEmpty str then acc 
    else recLettersOf (String.dropLeft 1 str) (acc ++ [String.left 1 str])

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
        Playing game -> playingScreen game


startingScreen : Element Msg
startingScreen =
    Element.column []
        [ text "Welcome to Hangman"
        , Input.button 
            [ Background.color (rgb 0.4 0.6 1.0)
            , padding 5
            ] 
            { onPress = Just Generate
            , label = text "Start" 
            }
        ]

playingScreen : Game -> Element Msg
playingScreen game =
    Element.column []
    [ Element.row 
        [ spacing 4 ] 
        ( game.letterBoxes |> List.map letterBoxView )
    , Element.row []
        [ hangmanView game.attempts
        , typingView
        ,  text game.wordToGuess
        ]
    ]
    
hangmanView : Int -> Element Msg
hangmanView attempts =
    Element.el 
    [ width (px 100)
    , height (px 100)
    , Background.color (rgb 0.7 0.7 0.7)
    ] 
    ( attempts |> String.fromInt |> text)

typingView : Element Msg
typingView =
    Input.text 
        [ Input.focusedOnLoad ]
        { label = Input.labelAbove [] (text "Type a letter" ) 
        , onChange = Typed 
        , placeholder = Nothing
        , text = ""
        }

letterBoxView : LetterBox -> Element Msg
letterBoxView letterBox = 
    Element.el 
        [ width (px 76)
        , height (px 84)
        , Font.size 64
        , Font.family 
            [ Font.typeface "Georgia"
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
        (text (stringOfLetterBox letterBox))
        
stringOfLetterBox : LetterBox -> String
stringOfLetterBox letterBox =
    case letterBox of
            Found letter -> letter
            Unknown -> "_"