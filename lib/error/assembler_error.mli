type error =
| ArgumentError of string
| UknownInstruction of string Syntax.expression
| SymbolRedefinition of string Syntax.expression
| UndefinedReference of string Syntax.expression
| TypeError of Syntax.argument

exception Chip8AsmException of error

val throw: error -> 'a
val string_of_error: error -> string
val print_parser_error_in_file: Parser_error.error -> string -> unit
val print_assembler_error_in_file: error -> string -> unit
