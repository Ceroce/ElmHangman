module Main exposing (..)
import Browser
import Browser.Events exposing (onAnimationFrameDelta)
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

type AlphaState = NotTried | Right | Wrong

-- A letter typed by the user (shown in black boxes)
type alias Alpha =
    { letter : Char
    , state : AlphaState
    }

 -- A placeholder for a letter of the word to guess   
type LetterFrame =
    Revealed Char
    | Concealed

type alias Game = 
    { wordToGuess : String
    , lettersTried : List Char
    , alphas : List Alpha
    , letterFrames : List LetterFrame
    , errorCount : Int
    }

type alias StartAnimation = 
    { time : Float -- ms
    }

type Model = 
    Starting StartAnimation
    | Playing Game

init : () -> ( Model, Cmd Msg )
init _ = 
    ( Starting 
        { time = 0.0 }
    , Cmd.none
    )


words = ["absolute", "behemoth", "cardinal", "destructive", "escape", "follow", "generate", "horny", "idiomatic", "jellyfish", "kettle", "lunatic", "multiple", "nothing", "oblivious", "precaution", "regretable", "species", "trouser", "universal", "veritable", "wisdom", "xenophobia", "yellow", "zenith"]

-- UPDATE

type Msg = 
    Generate 
    | Guess (Maybe String, List String)
    | Typed Char
    | OnAnimFrame Float

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
                    , alphas = initialAlphas
                    , letterFrames = determineLetterFrames [] word
                    , errorCount = 0
                    }

            in
                ( Playing game
                , Cmd.none
                )

        Typed letter ->
            case model of
                Playing game -> 
                    let lettersTried = letter :: game.lettersTried 
                        theLog = log "lettersTried" lettersTried
                    in
                        ( Playing 
                            { game | lettersTried = lettersTried
                            , letterFrames = determineLetterFrames lettersTried game.wordToGuess
                            , errorCount = numberOfErrors lettersTried game.wordToGuess }
                        , Cmd.none
                        )
                
                _ -> (model, Cmd.none)

        OnAnimFrame deltaTime ->
            case model of
                Starting startAnim -> 
                    ( Starting { startAnim | time = startAnim.time + deltaTime }
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

initialAlphas : List Alpha
initialAlphas = 
    List.map (\char -> { letter = char, state = NotTried }) (charsRange 'A' 'Z')


determineLetterFrames : List Char -> String -> List LetterFrame
determineLetterFrames lettersTried wordToGuess =
    let wordLetters = String.toList wordToGuess
    in
        List.map (determineLetterFrame lettersTried) wordLetters 

determineLetterFrame : List Char -> Char ->  LetterFrame
determineLetterFrame lettersTried letter  =
    if List.member letter lettersTried then
        Revealed letter
    else
        Concealed

numberOfErrors : List Char -> String -> Int
numberOfErrors lettersTried wordToGuess = 
    let wordLetters = String.toList wordToGuess
    in
        recNumberOfErrors lettersTried wordLetters 0
        
recNumberOfErrors : List Char -> List Char -> Int -> Int
recNumberOfErrors lettersTried wordLetters count =
    case lettersTried of
        [] -> count
        (letter::rest) ->
            if List.member letter wordLetters 
                then recNumberOfErrors rest wordLetters count
                else recNumberOfErrors rest wordLetters (count + 1)


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.Events.onAnimationFrameDelta OnAnimFrame

-- VIEW

view : Model -> Html Msg
view model =
    Element.layout [ Background.color (rgb255 251 245 228) ] <| 
    case model of
        Starting startAnim -> startingScreen startAnim.time
        Playing game -> playingScreen game


startingScreen : Float -> Element Msg
startingScreen animTime =
    Element.column 
        [ centerX
        , centerY
        ]
        [ Element.html (titleSvg animTime)
        , spacer
        , startButton
        ]

-- Needed because setting a spacing for the column does not work for the SVG
spacer =
    Element.el [height (px 30)] none

startButton =
    Input.button 
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

playingScreen : Game -> Element Msg
playingScreen game =
    Element.column 
    [ centerX
    , centerY
    , spacing 8
    ]
    [ Element.row 
        [ centerX
        , spacing 4 
        ] 
        ( game.letterFrames |> List.map letterFrameView )
    , Element.row [ centerX ]
        [ hangmanView game.errorCount
        ]
    , Element.row [ centerX, spacing 4 ] 
        (game.alphas |> List.take 13 |> List.map alphaButton)
    , Element.row [ centerX, spacing 4 ] 
        (game.alphas |> List.drop 13 |> List.map alphaButton)
    ]

hangmanView : Int -> Element Msg
hangmanView errorCount =
    Element.html (hangmanSvg errorCount)

letterFrameView : LetterFrame -> Element Msg
letterFrameView letterFrame = 
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
        ( (text << String.fromChar << charOfLetterFrame) letterFrame)
        
charOfLetterFrame : LetterFrame -> Char
charOfLetterFrame letterFrame =
    case letterFrame of
            Revealed letter -> letter
            Concealed -> '_'

charsRange : Char -> Char -> List Char
charsRange start end = 
    List.range (Char.toCode start) (Char.toCode end)
    |> List.map Char.fromCode

alphaButton : Alpha -> Element Msg
alphaButton alpha =
    Input.button 
        [ width (px 50)
        , height (px 50)
        , Background.color (rgb 0 0 0)
        , Font.size 24
        , Font.family 
            [ Font.typeface "Courier"
            , Font.monospace 
            ]
        , Font.center
        , Font.color (rgb 1 1 1)
        ]
        { onPress = Just (Typed alpha.letter)
        , label = text (String.fromChar alpha.letter)
        }