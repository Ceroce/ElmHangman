module TitleSvg exposing (titleSvg)

import List as List
import Svg exposing (..)
import Svg.Attributes exposing (..)

titleSvg =
    svg 
        [ width "612px", height "173px", viewBox "0 0 612 173", version "1.1" ] 
        [ desc [] [ text "Created with Sketch." ]
        , g [ id "Page-1", stroke "none", strokeWidth "1", fill "none", fillRule "evenodd" ] 
            [ g [ id "Title", stroke "#785B3E", strokeWidth "5" ] 
                sticks
        ] 
    ]

sticks = [stick0, stick1, stick2, stick3, stick4, stick5, stick6, stick7, stick8, stick9, stick10, stick11, stick12, stick13, stick14, stick15, stick16, stick17, stick18, stick19]
stick0 = line [ x1 "2.5", y1 "4", x2 "2.5", y2 "169", id "Stick0" ] []
stick1 = line [ x1 "2.66260163", y1 "83.5", x2 "164.337398", y2 "83.5", id "Stick1", strokeLinecap "square" ] []
stick2 = line [ x1 "70.5", y1 "3.66260163", x2 "70.5", y2 "165.337398", id "Stick2", strokeLinecap "square" ] []
stick3 = line [ x1 "69.6666667", y1 "165.340164", x2 "116.333333", y2 "5.65983607", id "Stick3", strokeLinecap "square" ] []
stick4 = line [ x1 "117.666667", y1 "164.340164", x2 "164.333333", y2 "4.65983607", id "Stick4", strokeLinecap "square", transform "translate(141.000000, 84.500000) scale(-1, 1) translate(-141.000000, -84.500000) " ] []
stick5 = line [ x1 "164.5", y1 "164.337398", x2 "164.5", y2 "2.66260163", id "Stick5", strokeLinecap "square" ] []
stick6 = line [ x1 "165", y1 "165", x2 "241.336207", y2 "4.65983607", id "Stick6", strokeLinecap "square", transform "translate(203.500000, 84.500000) scale(-1, 1) translate(-203.500000, -84.500000) " ] []
stick7 = line [ x1 "242.5", y1 "6.66115702", x2 "242.5", y2 "165.338843", id "Stick7", strokeLinecap "square" ] []
stick8 = Svg.path [ d "M292,6 C264.938047,6 243,41.5933624 243,85.5 C243,129.406638 264.938047,165 292,165 C319.061953,165 341,129.406638 341,85.5", id "Stick8" ] []
stick9 = line [ x1 "342.342105", y1 "86.5", x2 "293.657895", y2 "86.5", id "Stick9", strokeLinecap "square" ] []
stick10 = line [ x1 "342.5", y1 "168.337398", x2 "342.5", y2 "6.66260163", id "Stick10", strokeLinecap "square" ] []
stick11 = line [ x1 "342.666667", y1 "167.340164", x2 "389.333333", y2 "7.65983607", id "Stick11", strokeLinecap "square", transform "translate(366.000000, 87.500000) scale(-1, 1) translate(-366.000000, -87.500000) " ] []
stick12 = line [ x1 "389.666667", y1 "167.340164", x2 "436.333333", y2 "7.65983607", id "Stick12", strokeLinecap "square" ] []
stick13 = line [ x1 "437.5", y1 "169.337398", x2 "437.5", y2 "7.66260163", id "Stick13", strokeLinecap "square" ] []
stick14 = line [ x1 "435.666667", y1 "169.340164", x2 "482.333333", y2 "9.65983607", id "Stick14", strokeLinecap "square" ] []
stick15 = line [ x1 "483.666667", y1 "167.340164", x2 "530.333333", y2 "7.65983607", id "Stick15", strokeLinecap "square", transform "translate(507.000000, 87.500000) scale(-1, 1) translate(-507.000000, -87.500000) " ] []
stick16 = line [ x1 "437.661972", y1 "85.75", x2 "530.338028", y2 "87.25", id "Stick16", strokeLinecap "square" ] []
stick17 = line [ x1 "530.5", y1 "168.337398", x2 "530.5", y2 "6.66260163", id "Stick17", strokeLinecap "square" ] []
stick18 = line [ x1 "531", y1 "168", x2 "607.336207", y2 "7.65983607", id "Stick18", strokeLinecap "square", transform "translate(569.500000, 87.500000) scale(-1, 1) translate(-569.500000, -87.500000) " ] []
stick19 = line [ x1 "608.5", y1 "9.66115702", x2 "608.5", y2 "168.338843", id "Stick19", strokeLinecap "square" ] []