type error =
  | ParsingError   of Lexing.position * string
  | CannotOpenFile of string * string

exception Chip8ParserException of error

let throw error =
  raise (Chip8ParserException error)

let print_error_in_file_position (position: Lexing.position) msg filename =
  let input_file = open_in filename in
  seek_in input_file position.pos_bol;
  let file_line = input_line input_file in
  let column = position.pos_cnum - position.pos_bol in
  let line = position.pos_lnum in
  Printf.printf "Error in file %s, line %d, column %d \n" filename line column;
  Printf.printf "%d | %s \n" line file_line;
  print_newline ();
  print_string @@ "Message: " ^ msg;
  close_in input_file

let string_of_error error =
  match error with
  | ParsingError(position, msg) ->
    let line = position.pos_lnum |> string_of_int in
    let column = position.pos_cnum - position.pos_bol |> string_of_int in
    "Parsing error in line: " ^ line ^ " column: " ^ column  ^ ". " ^ msg
  | CannotOpenFile (filename, msg) ->
    "Cannot open file \"" ^ filename ^ "\": " ^ msg ^ "\n"

let print_error_in_file error filename =
  match error with
  | ParsingError (pos, msg) -> print_error_in_file_position pos msg filename
  | CannotOpenFile (_, _) -> print_endline @@ string_of_error error
