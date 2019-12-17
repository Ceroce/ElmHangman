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

import HangmanSvg exposing (hangmanSvg)
import TitleSvg exposing (titleSvg)

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
    Revealed String
    | Concealed

type alias Game = 
    { wordToGuess : String
    , lettersTried : List String
    , letterBoxes : List LetterBox
    , errorCount : Int
    }

type Model = 
    Starting
    | Playing Game

init : () -> ( Model, Cmd Msg )
init _ = 
    ( Starting
    , Cmd.none
    )


words = ["absolute", "behemoth", "cardinal", "destructive", "escape", "follow", "generate", "horny", "idiomatic", "jellyfish", "kettle", "lunatic", "multiple", "nothing", "oblivious", "precaution", "regretable", "species", "trouser", "universal", "veritable", "wisdom", "xenophobia", "yellow", "zenith"]

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
                    , errorCount = 0
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
                            , errorCount = numberOfErrors lettersTried game.wordToGuess }
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
        Revealed letter
    else
        Concealed

lettersOf : String -> List String
lettersOf str =
    recLettersOf str []

recLettersOf : String -> List String -> List String
recLettersOf str acc =
    if String.isEmpty str then acc 
    else recLettersOf (String.dropLeft 1 str) (acc ++ [String.left 1 str])

numberOfErrors : List String -> String -> Int
numberOfErrors lettersTried wordToGuess = 
    let wordLetters = lettersOf wordToGuess
    in
        recNumberOfErrors lettersTried wordLetters 0
        
recNumberOfErrors letter wordLetters count =
    case letter of
        [] -> count
        (x::xs) ->
            if List.member x wordLetters 
                then recNumberOfErrors xs wordLetters count
                else recNumberOfErrors xs wordLetters (count + 1)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

-- VIEW

view : Model -> Html Msg
view model =
    Element.layout [ Background.color (rgb255 251 245 228) ] <| 
    case model of
        Starting -> startingScreen
        Playing game -> playingScreen game


startingScreen : Element Msg
startingScreen =
    Element.column [ centerX, centerY]
        [ Element.html titleSvg
        , Input.button 
            [ centerX
            , Background.color (rgb255 39 176 239)
            , padding 8
            , Border.rounded 6
            , Border.shadow 
                { color = (rgba 0 0 0 0.5 )
                , offset = ( 0, 2)
                , blur = 4
                , size = 0
                }
            , Font.size 32
            , Font.family 
                [ Font.typeface "Arial"
                , Font.sansSerif 
                ]
            , Font.center
            , Font.color (rgb 1 1 1)
            ] 
            { onPress = Just Generate
            , label = text "START" 
            }
        ]

playingScreen : Game -> Element Msg
playingScreen game =
    Element.column []
    [ Element.row 
        [ spacing 4 ] 
        ( game.letterBoxes |> List.map letterBoxView )
    , Element.row []
        [ hangmanView game.errorCount
        , typingView
        -- ,  text game.wordToGuess
        ]
    ]

hangmanView : Int -> Element Msg
hangmanView errorCount =
    Element.html (hangmanSvg errorCount)

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
            Revealed letter -> letter
            Concealed -> "_"