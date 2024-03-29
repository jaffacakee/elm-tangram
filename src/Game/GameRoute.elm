module Game.GameRoute exposing (..)

import Game.Levels.Level1 as Level1 exposing (..)
import Game.Levels.Level2 as Level2 exposing (..)
import Game.Levels.Level3 as Level3 exposing (..)
import Game.Levels.Level4 as Level4 exposing (..)
import Game.Levels.Level5 as Level5 exposing (..)
--import Game.Levels.Level6 as Level6 exposing (..)
import Grid exposing (Grid, Square)
import Puzzles exposing (Puzzle, Position)
import Dict


type alias GameState =
    { level : Int
    , status : Status
    , puzzles : List Puzzle
    , grid : Grid
    }

type Status
    = HomePage
    | Playing
    | Won
    | Totur

generateLevelGrid : Int -> Grid
generateLevelGrid level =
    case level of
        1 ->
            Level1.generateGrid

        2 ->
            Level2.generateGrid

        3 ->
            Level3.generateGrid

        4 ->
            Level4.generateGrid

        _ ->
            Level5.generateGrid

generateLevelPuzzles : Int -> List Puzzle
generateLevelPuzzles level =
    case level of
        1 ->
            Level1.generatePuzzles

        2 ->
            Level2.generatePuzzles

        3 ->
            Level3.generatePuzzles

        4 ->
            Level4.generatePuzzles
        
        _ ->
            Level5.generatePuzzles

updateLevelGameStatus : Int -> Position -> GameState -> GameState
updateLevelGameStatus id position gs =
    let
        newgrid =
            let
                dragpuzzle =
                    gs.puzzles
                        |> List.map (\item -> (item.id, item))
                        |> Dict.fromList
                        |> Dict.get id
            in
            { squares = updateSquares dragpuzzle position gs.grid
            , width = gs.grid.width
            , height = gs.grid.height }
    in
    { level = gs.level
    , status = checkStatus newgrid
    , puzzles = updatePuzzles id position gs.puzzles
    , grid = newgrid
    }


checkStatus : Grid -> Status
checkStatus grid =
    let
        count =
            grid.squares
                |> List.concat
                |> List.filter (\a -> a.isCovered == True )
                |> List.length
    in
    if count == grid.width * grid.height then
        Won
    else
        Playing

updatePuzzles : Int -> Position -> List Puzzle -> List Puzzle
updatePuzzles id position puzzles =
    if position.x > -1 then
        List.filter ( \a -> a.id /= id ) puzzles
    else
        puzzles

updateSquares : Maybe Puzzle -> Position -> Grid -> List ( List Square )
updateSquares dragpuzzle position grid =
    grid.squares
        |> List.map 
            (List.map
              (\a ->
                  updateSquare a dragpuzzle position
              )
            )

updateSquare : Square -> Maybe Puzzle -> Position -> Square
updateSquare square dragpuzzle position =
    case dragpuzzle of
        Nothing ->
            square

        Just puzzle ->
            let
                covered =
                    if square.position.y == position.y
                        && square.position.x >= ( position.x - puzzle.shape.up ) 
                        && square.position.x <= ( position.x + puzzle.shape.down ) then
                        True
                    else if square.position.x == position.x
                        && square.position.y >= ( position.y - puzzle.shape.left ) 
                        && square.position.y <= ( position.y + puzzle.shape.right )
                        then
                        True
                    else
                        False
            in
            if covered then
                { isCovered = True, position = square.position }
            else
                square