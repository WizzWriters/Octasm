type error =
| ArgumentError of string

exception Chip8AsmException of error

let throw error =
  raise (Chip8AsmException error)

let string_of_error error =
  match error with
  | ArgumentError msg -> msg
