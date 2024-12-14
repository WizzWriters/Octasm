open Menhir_parser

module I = MenhirInterpreter

let get_error env =
  match I.stack env with
  | lazy Nil -> "Program should start with a valid directive (.text or .data)."
  | lazy (Cons (I.Element (state,_,_,_), _)) ->
    try Menhir_parser_messages.message (I.number state) with
    | Not_found -> "Unknown error"

let rec incremental_parse lexbuf checkpoint =
  match checkpoint with
  | I.Accepted return_value -> return_value
  | I.Rejected ->
    let start_p = Lexing.lexeme_start_p lexbuf in
    let end_p = Lexing.lexeme_end_p lexbuf in
    Parser_error.throw @@
      Parser_error.ParsingError({start_p; end_p}, "Input rejected")
  | I.InputNeeded _ ->
    let token = Chip8_lexer.read lexbuf in
    let start_position = lexbuf.lex_start_p in
    let end_position = lexbuf.lex_curr_p in
    let next = I.offer checkpoint (token, start_position, end_position) in
    incremental_parse lexbuf next
  | I.Shifting _ | I.AboutToReduce _ ->
    let next = I.resume checkpoint in
    incremental_parse lexbuf next
  | I.HandlingError env ->
    let start_p = Lexing.lexeme_start_p lexbuf in
    let end_p = Lexing.lexeme_end_p lexbuf in
    Parser_error.throw @@
      Parser_error.ParsingError({start_p; end_p}, get_error env)

let parse entry_point lexbuf =
  incremental_parse lexbuf (entry_point lexbuf.lex_curr_p)

let parse_program_from_string str =
  parse Incremental.program (Lexing.from_string str)

let parse_program_from_file filename =
  try
    let input_chanel = open_in filename in
    let lexbuf = Lexing.from_channel input_chanel in
    parse Incremental.program lexbuf
  with
  | Sys_error msg ->
    Parser_error.throw (Parser_error.CannotOpenFile (filename, msg))
