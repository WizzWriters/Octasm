type error =
| ArgumentError of string

exception Chip8AsmException of error

val throw: error -> 'a
val string_of_error: error -> string
val print_parser_error_in_file: Parser_error.error -> string -> unit
