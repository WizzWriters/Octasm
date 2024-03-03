open Parser_error

type error =
| ArgumentError of string

exception Chip8AsmException of error

let throw error =
  raise (Chip8AsmException error)

let string_of_error error =
  match error with
  | ArgumentError msg -> msg

let get_file_line (position: location) filename =
  let input_file = open_in filename in
  seek_in input_file position.start_p.pos_bol;
  let file_line = input_line input_file in
  close_in input_file;
  file_line

let padd_output length =
  for _ = length downto 1 do
    print_char ' '
  done

let print_underscore start_column end_column =
  let length = end_column - start_column in
  print_string "\027[31m"; (* Start to print in red *)
  padd_output start_column;
  for _ = length downto 1 do
    print_char '^'
  done;
  print_string "\027[0m" (* Back to white *)

let print_line_with_error line_number start_column end_column line =
  let line_num_str = Printf.sprintf "%d | " line_number in
  let padding_length = String.length line_num_str in
  print_endline @@ line_num_str ^ line;
  padd_output padding_length;
  print_underscore start_column end_column

let print_error_in_file_position (position: location) msg filename =
  let file_line = get_file_line position filename in
  let (start_column, end_column) = get_columns position in
  let line = position.start_p.pos_lnum in
  Printf.printf "Error in file %s, " filename;
  Printf.printf "line %d, columns %d:%d \n" line start_column end_column;
  print_line_with_error line start_column end_column file_line;
  print_newline ();
  print_string @@ "Message: " ^ msg

let print_parser_error_in_file error filename =
  match error with
  | ParsingError (pos, msg) ->
    print_error_in_file_position pos msg filename
  | CannotOpenFile (_, _) -> print_endline @@ Parser_error.string_of_error error
