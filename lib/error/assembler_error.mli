type error =
| InternalError of string
| ArgumentError of string
| UknownInstruction of string Syntax.expression
| UknownRegister of string Syntax.expression
| UknownType of string Syntax.expression
| BadRegister of string Syntax.expression
| SymbolRedefinition of string Syntax.expression
| UndefinedReference of string Syntax.expression
| ValueOutOfBounds of int Syntax.expression
| TypeError of Syntax.argument
| InvalidValueDefinition of string Syntax.expression * string

exception Chip8AsmException of error

val throw: error -> 'a
val string_of_error: error -> string
val print_parser_error_in_file: Parser_error.error -> string -> unit
val print_assembler_error_in_file: error -> string -> unit
