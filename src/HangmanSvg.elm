module HangmanSvg exposing (hangmanSvg)

import List as List
import Svg exposing (..)
import Svg.Attributes exposing (..)

-- Converted using https://levelteams.com/svg-to-elm

hangmanSvg errorCount =
    svg 
        [ width "109px"
        , height "198px"
        , viewBox "0 0 109 198"
        , version "1.1" 
        ] 
        [ desc [] 
            [ text "Created with Sketch." ]
            , g 
                [ id "Page-1"
                , stroke "none"
                , strokeWidth "1"
                , fill "none"
                , fillRule "evenodd" 
                ] 
                [ g 
                    [ id "Game"
                    , transform "translate(-69.000000, -208.000000)" 
                    ] 
                    [ rect 
                        [ id "Rectangle"
                        , fill "#E9E4D4"
                        , x "50"
                        , y "194"
                        , width "147"
                        , height "226" 
                        ] 
                        []
                    , g 
                        [ id "Hangman"
                        , transform "translate(71.000000, 210.000000)"
                        , stroke "#785B3E"
                        , strokeLinecap "square"
                        , strokeWidth "5" 
                        ] 
                        (sticksForErrors errorCount)
                    ] 
                ]
            ]

sticksForErrors errorCount = 
    List.take errorCount sticks

sticks = [ stick0, stick1, stick2, stick3, stick4, stick5, stick6, stick7, stick8] 

stick0 = line [ x1 "1.75", y1 "192.75", x2 "38.25", y2 "193.25", id "Stick0" ] []
stick1 = line [ x1 "19.5", y1 "191.5", x2 "19.25", y2 "4.25", id "Stick1" ] []
stick2 = line [ x1 "0.662601626", y1 "1.5", x2 "91.25", y2 "1.25", id "Stick2" ] []
stick3 = line [ x1 "77.25", y1 "33.25", x2 "77", y2 "4.5", id "Stick3" ] []
stick4 = ellipse [ id "Stick4", cx "77", cy "60.5", rx "20", ry "25.5" ] []
stick5 = line [ x1 "77.25", y1 "136.25", x2 "77.125", y2 "87.875", id "Stick5" ] []
stick6 = line [ x1 "51.25", y1 "104.25", x2 "104.25", y2 "104.25", id "Stick6"] []
stick7 = line [ x1 "55.5", y1 "171.5", x2 "76.5", y2 "137.5", id "Stick7", transform "translate(66.000000, 154.500000) scale(-1, -1) translate(-66.000000, -154.500000) " ] []
stick8 = line  [ x1 "99.25", y1 "172.25", x2 "78.25", y2 "137.25", id "Stick8"] []