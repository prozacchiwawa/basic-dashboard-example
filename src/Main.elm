module Main exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Http
import Time exposing (Time)

type Msg
    = Tick
    | PsResult (Result Http.Error String)
    | NetstatResult (Result Http.Error String)
    

type alias Model =
    { psContainsSshd : Int
    , netstatContainsPort8009 : Bool
    , updating : Int
    , error : String
    }

squareStyle color =
    [ "background-color" => color
    , "width" => "100px"
    , "height" => "100px"
    , "position" => "relative"
    , "color" => "white"
    ]
    
view model =
    let s1color = if model.psContainsSshd > 1 then "red" else "green" in
    let s2color = if model.netstatContainsPort8009 then "green" else "red" in
    div []
        [ div [style (squareStyle s1color)] [text "ps"]
        , div [style (squareStyle s2color)] [text "netstat"]
        , div [] [text model.error]
        ]

update msg model =
    let erun f res =
        case res of
            Ok str -> f str
            Err e ->
                { model | error = toString e, updating = model.updating - 1 } ! []
    in
    case msg of
        Tick ->
            if model.updating == 0 then
                { model | updating = 2 } !
                    [ Http.getString "/ps" |> Http.send PsResult
                    , Http.getString "/netstat" |> Http.send NetstatResult
                    ]
            else
                model ! []

        PsResult res ->
            let psupdate str =
                let ps =
                    String.lines str
                    |> List.filter (\s -> String.indices "sshd" s /= [])
                    |> List.length
                in
                { model
                | psContainsSshd = ps
                , updating = model.updating - 1
                } ! []
            in
            erun psupdate res
                
        NetstatResult res ->
            let nsupdate str =
                let ns =
                    String.lines str
                    |> List.filter (String.words >> List.any ((==) ":::8009"))
                    |> List.length
                in
                { model
                | netstatContainsPort8009 = ns /= 0
                , updating = model.updating - 1
                } ! []
            in
            erun nsupdate res

main =
    Html.program
        { init =
              { psContainsSshd = 0
              , netstatContainsPort8009 = False
              , updating = 0
              , error = ""
              } ! []
        , view = view
        , update = update
        , subscriptions = always (Time.every (Time.second * 15.0) (always Tick))
        }

(=>) = (,)
