type location = { start_p: Lexing.position; end_p: Lexing.position }

type error =
  | ParsingError   of location * string
  | CannotOpenFile of string * string

exception Chip8ParserException of error

let throw error =
  raise (Chip8ParserException error)

let get_columns position =
  let start_column = position.start_p.pos_cnum - position.start_p.pos_bol in
  let end_column = position.end_p.pos_cnum - position.end_p.pos_bol in
  (start_column, end_column)

let string_of_error error =
  match error with
  | ParsingError(position, msg) ->
    let line = position.start_p.pos_lnum |> string_of_int in
    let (start_column, end_column) = get_columns position in
    Printf.sprintf "Parsing error in line %s " line ^
    Printf.sprintf "columns %d:%d. %s" start_column end_column msg
  | CannotOpenFile (filename, msg) ->
    "Cannot open file \"" ^ filename ^ "\": " ^ msg ^ "\n"
