
type error =
| ParsingError   of Lexing.position * string
| CannotOpenFile of string * string

exception Chip8Exception of error

let throw error =
  raise (Chip8Exception error)

let string_of_error error =
  match error with
  | ParsingError(position, msg) ->
    let line = position.pos_lnum |> string_of_int in
    let column = position.pos_cnum - position.pos_bol |> string_of_int in
    "Parsing error at " ^ line ^ ":" ^ column  ^ " : " ^ msg
  | CannotOpenFile (filename, msg) ->
    "Cannot open file \"" ^ filename ^ "\": " ^ msg ^ "\n"
