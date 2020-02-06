module Main exposing (..)
import Browser
import Browser.Events exposing (onAnimationFrameDelta, onKeyPress)
import Debug exposing (..)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Json.Decode as Decode
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

-- Whether the game is finished
type FinishedState = NotFinished | Won | Lost

type alias Game = 
    { wordToGuess : String
    , lettersTried : List Char
    , alphas : List Alpha
    , letterFrames : List LetterFrame
    , errorCount : Int
    , finishedState : FinishedState
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
    | ControlKey String

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
                    , finishedState = NotFinished
                    }

            in
                ( Playing game
                , Cmd.none
                )

        Typed letter ->
            case model of
                Playing game -> 
                    let lettersTried = letter :: game.lettersTried
                        alphas = updateAlphas game.alphas letter game.wordToGuess
                        errorCount = numberOfErrors alphas
                        finishedState = updateFinishedState errorCount alphas (String.toList game.wordToGuess)
                        theLog = log "lettersTried" lettersTried
                    in
                        ( Playing 
                            { game | lettersTried = lettersTried
                            , alphas = alphas
                            , letterFrames = determineLetterFrames lettersTried game.wordToGuess
                            , errorCount = errorCount 
                            , finishedState = finishedState }
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

        ControlKey _ ->
            (model, Cmd.none)
        

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

updateAlphas : List Alpha -> Char -> String -> List Alpha
updateAlphas alphas letterTyped wordToGuess =
    List.map (\alph -> if alph.letter == letterTyped then alphaForLetterInWord letterTyped wordToGuess else alph) alphas  

alphaForLetterInWord : Char -> String -> Alpha
alphaForLetterInWord letter word =
    { letter = letter 
    , state = alphaStateForLetterInWord letter word
    }

alphaStateForLetterInWord : Char -> String -> AlphaState
alphaStateForLetterInWord letter word =
    let isLetterInWord = String.toList word |> List.member letter
    in
        if isLetterInWord then Right else Wrong

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

updateFinishedState : Int -> List Alpha -> List Char -> FinishedState
updateFinishedState errorCount alphas lettersToGuess =
    let isGameLost = errorCount >= lostGameErrorCount
        numberOfUniqueLetters = List.length ( uniqueLettersOf lettersToGuess )
        isGameWon = (List.filter (\a -> a.state == Right) alphas |> List.length) == numberOfUniqueLetters
    in
        case (isGameLost, isGameWon) of
           (False, False) -> NotFinished
           (True, _) -> Lost
           (_, True) -> Won

lostGameErrorCount = 9

numberOfErrors : List Alpha -> Int
numberOfErrors alphas = 
    recNumberOfErrors alphas 0

recNumberOfErrors : List Alpha -> Int -> Int
recNumberOfErrors alphas count =
    case alphas of
        [] -> count
        x::xs -> if x.state == Wrong then recNumberOfErrors xs (count + 1) else recNumberOfErrors xs count

uniqueLettersOf : List Char -> List Char 
uniqueLettersOf word = 
    List.foldl (\c l -> if List.member c l then l else c :: l ) [] word

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
    [ onAnimationFrameDelta OnAnimFrame
    , onKeyPress keyDecoder
    ]

keyDecoder : Decode.Decoder Msg
keyDecoder = 
    let keyValue = Decode.field "key" Decode.string
    in
        Decode.map toKey keyValue
    
toKey : String -> Msg
toKey keyValue = 
    case String.uncons keyValue of
        Just ( char, "" ) -> Typed (Char.toUpper char)
        _ -> ControlKey keyValue

-- VIEW

view : Model -> Html Msg
view model =
    Element.layout [ Background.color (rgb255 251 245 228) ] <| 
    case model of
        Starting startAnim -> startingScreen startAnim.time
        Playing game -> gameScreen game


startingScreen : Float -> Element Msg
startingScreen animTime =
    Element.column 
        [ centerX
        , centerY
        ]
        [ Element.html (titleSvg animTime)
        , vSpacer 30
        , playButton "START" 32
        ]

-- Needed because setting a spacing for the column does not work for the SVG
vSpacer theHeight =
    Element.el [height (px theHeight)] none

playButton : String -> Int -> Element Msg
playButton caption fontSize =
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
        , Font.size fontSize
        , Font.family 
            [ Font.typeface "Arial"
            , Font.sansSerif 
            ]
        , Font.center
        , Font.color (rgb 1 1 1)
        ] 
        { onPress = Just Generate
        , label = text caption 
        }

gameScreen : Game -> Element Msg
gameScreen game =
    let thePlayScreen = playScreen game
    in
        case game.finishedState of
            NotFinished -> thePlayScreen
            Won -> Element.el [ width fill, height fill, Element.inFront wonView ] thePlayScreen
            Lost -> Element.el [ width fill, height fill, Element.inFront lostView ] thePlayScreen

playScreen : Game -> Element Msg
playScreen game = 
    Element.column 
        [ centerX
        , centerY
        , spacing 16
        ]
        [ Element.row 
            [ centerX
            , spacing 4 
            ] 
            ( game.letterFrames |> List.map letterFrameView )
        , Element.row [ centerX ]
            [ hangmanView game.errorCount
            ]
        , alphaButtonsView game.alphas
        ]

alphaButtonsView : List Alpha -> Element Msg
alphaButtonsView alphas =
    Element.column [ centerX, spacing 4 ]
        [ Element.row [ spacing 4 ] 
            (alphas |> List.take 13 |> List.map alphaButton)
        , Element.row [ spacing 4 ] 
            (alphas |> List.drop 13 |> List.map alphaButton)
        ]

wonView : Element Msg
wonView = finishedView (rgba 0 0.8 0 0.7) "You Win!"

lostView : Element Msg
lostView =
    finishedView (rgba 1 0 0 0.7) "You lose!"

finishedView backgroundColor caption =
    Element.el 
        [ width fill
        , height fill
        , Background.color backgroundColor]
        ( Element.column 
            [ centerX
            , centerY
            , spacing 40 
            ]
            [ Element.el 
                [ centerX
                , centerY
                , Font.size 80
                , Font.color (rgb 1 1 1)] 
                (text caption)
            , playButton "Play again" 32]
        )

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
        , Background.color (backgroundColorForAlphaState alpha.state)
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

backgroundColorForAlphaState : AlphaState -> Color
backgroundColorForAlphaState state =
    case state of
       NotTried -> (rgb 0 0 0)
       Right -> (rgb 0 0.8 0)
       Wrong -> (rgb 1 0 0)
