{
  open Menhir_parser

  let symbols = [
    ',' , COMMA;
  ]

  let directives = [
    ".text", DIRECTIVE_TEXT;
    ".data", DIRECTIVE_DATA;
  ]

  let fill hashtbl list = List.iter
    (fun (elem, token) -> Hashtbl.add hashtbl elem token)
    list

  let symbol_table = Hashtbl.create (List.length symbols)
  let directive_table = Hashtbl.create (List.length directives)

  let _ = fill symbol_table symbols
  let _ = fill directive_table directives

  let hashtbl_lookup_char lexbuf hashtbl =
    let matched_string = Lexing.lexeme lexbuf in
    let symbol = String.get matched_string 0 in
    Hashtbl.find hashtbl symbol

  let hashtbl_lookup_str lexbuf hashtbl =
    let matched_string = Lexing.lexeme lexbuf in
    Hashtbl.find hashtbl matched_string

  let skip_n_letters str n =
    let len = String.length str in
    String.sub str n (len - 1)

  let int_of_const const_str =
    int_of_string (skip_n_letters const_str 1)

  let name_of_name_ref name_ref =
    skip_n_letters name_ref 1

  let get_register_name reg =
    skip_n_letters reg 1

  let typename_of_type t = 
    skip_n_letters t 1

  let trim_label label =
    let len = String.length label in
    String.sub label 0 (len - 1)
}

let upper_case_letter = ['A' - 'Z']
let lower_case_letter = ['a' - 'z']
let letter = upper_case_letter | lower_case_letter
let digit = ['0' - '9']
let alphanumeric = letter | digit

let whitespace = [' ' '\t']+
let newline = '\n' | "\r\n"
let symbol = [',' '=']

let name = letter (alphanumeric | ['_'])*
let label = '_'* name ':'
let register = '%' alphanumeric+
let number = digit+ | "0x" (digit | ['A' - 'F'])+ | "0b" ['0' '1']+
let const = '$' number
let name_ref = '$' name
let directive = ".text" | ".data"
let type = '.' name

rule read =
  parse
  | whitespace { read lexbuf }
  | newline    { Lexing.new_line lexbuf; read lexbuf }
  | register   { REGISTER (Lexing.lexeme lexbuf |> get_register_name) }
  | const      { NUMBER (Lexing.lexeme lexbuf |> int_of_const) }
  | name_ref   { NAME_REF (Lexing.lexeme lexbuf |> name_of_name_ref) }
  | label      { LABEL (Lexing.lexeme lexbuf |> trim_label ) }
  | name       { NAME (Lexing.lexeme lexbuf) }
  | directive  { hashtbl_lookup_str lexbuf directive_table }
  | type       { TYPENAME (Lexing.lexeme lexbuf |> typename_of_type ) }
  | symbol     { hashtbl_lookup_char lexbuf symbol_table }
  | "#"       { read_comment_line lexbuf }
  | "/*"       { read_comment_block lexbuf }
  | eof        { EOF }
  | _ {
    let curr_char = Lexing.lexeme lexbuf in
    let position = Lexing.lexeme_start_p lexbuf in
    Parser_error.throw
      (Parser_error.ParsingError(position, "Unexpected character: " ^ curr_char)) }

and read_comment_line =
  parse
  | '\n'       { Lexing.new_line lexbuf; read lexbuf }
  | eof        { EOF }
  | _          { read_comment_line lexbuf }

and read_comment_block =
  parse
  | '\n'       { Lexing.new_line lexbuf; read_comment_block lexbuf }
  | "*/"       { read lexbuf }
  | eof        {
    let position = Lexing.lexeme_start_p lexbuf in
    Parser_error.throw (Parser_error.ParsingError(position, "Unclosed comment block")) }
  | _          { read_comment_block lexbuf }
