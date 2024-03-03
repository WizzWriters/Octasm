type location = { start_p: Lexing.position; end_p: Lexing.position }
val get_columns: location -> int * int

type error =
  | ParsingError   of location * string
  | CannotOpenFile of string * string

exception Chip8ParserException of error

val throw: error -> 'a
val string_of_error: error -> string
