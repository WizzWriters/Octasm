type error =
  | ParsingError   of Lexing.position * string
  | CannotOpenFile of string * string

exception Chip8ParserException of error

val throw: error -> 'a
val string_of_error: error -> string
val print_error_in_file: error -> string -> unit
