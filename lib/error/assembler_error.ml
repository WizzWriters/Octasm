open Parser_error
open Syntax

type error =
| ArgumentError of string
| UknownInstruction of string expression
| SymbolRedefinition of string expression
| UndefinedReference of string expression
| TypeError of argument

exception Chip8AsmException of error

let throw error =
  raise (Chip8AsmException error)

let string_of_error error =
  match error with
  | ArgumentError msg -> msg
  | UknownInstruction parsed_instruction ->
    let instruction_name = parsed_instruction.value in
    Printf.sprintf "Uknown instruction: %s." instruction_name
  | SymbolRedefinition symbol ->
    let symbol_name = symbol.value in
    Printf.sprintf "Redefinition of symbol \"%s\"." symbol_name
  | UndefinedReference symbol ->
    let symbol_name = symbol.value in
    Printf.sprintf "Undefined reference to \"%s\"." symbol_name
  | TypeError _ -> "Value does not match the expected type."

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
  print_endline @@ "Message: " ^ msg

let print_parser_error_in_file error filename =
  match error with
  | ParsingError (pos, msg) ->
    print_error_in_file_position pos msg filename
  | CannotOpenFile (_, _) -> print_endline @@ Parser_error.string_of_error error

let print_assembler_error_in_file error filename =
  match error with
  | UknownInstruction name
  | SymbolRedefinition name
  | UndefinedReference name ->
    let msg = string_of_error error in
    let location = { start_p = name.start_p; end_p = name.end_p } in
    print_error_in_file_position location msg filename
  | TypeError argument ->
    let msg = string_of_error error in
    let (start_p, end_p) = get_location_of_argument argument in
    let location = { start_p; end_p } in
    print_error_in_file_position location msg filename
  | _ -> ()
