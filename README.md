# ElmHangman

A Hangman game written in Elm.

[Try it now](build/index.html)



## Description

This is a small hangman game that I wrote to learn more about Elm. Therefore some functions may be mis-named, some may be inefficient and overall the code may not respect Elm's idioms.

The game could be improved but I chose to move on. For instance, the dictionary only contains 26 words which show in the JavaScript code. Graphics and the way that games are run are simplistic too.



You might find the following interesting, though:

- the elm-ui package is used so I don't have to bother with CSS. See how SVG is embedded.
- the start animation (see TitleSvg.elm)
- picking a random word among a list

SVGs were drawn in Sketch and converted to Elm code thanks to [Elm-to-SVG](https://levelteams.com/svg-to-elm). I cut the big function manually into smaller ones so each stick was separate.



## License

Do whatever you want with this code.

