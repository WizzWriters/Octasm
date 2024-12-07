let usage_msg = " <input_file> -o <output_file>"

let input_file = ref ""

let anon_fun filename =
  if input_file.contents = "" then
    input_file := filename
  else
    Assembler_error.throw @@
      ArgumentError ("Multiple input files specified.")

let speclist = [
  ("-o", Arg.Set_string Options.output_file, "Set output file name");
  ("--no-entry-point", Arg.Set Options.no_entry_point,  "Don't generate jump to entry point")
]

let parse_argv () =
  try
    Arg.parse speclist anon_fun usage_msg;
    true
  with
  | Assembler_error.Chip8AsmException error ->
    print_endline ("Error: " ^ Assembler_error.string_of_error error);
    false

let get_default_output_filename input_filename =
  let filename = Filename.remove_extension input_filename in
  filename ^ ".ch8"

let save_to_file program_bytes =
  let output_file_name =
    if !Options.output_file = "" then
      get_default_output_filename !input_file
    else !Options.output_file in
  let output = open_out_bin output_file_name in
  output_bytes output program_bytes;
  close_out output

let assemble filename =
  if filename = "" then
    (print_endline "Input file not provided"; false)
  else try
    let parsed_program = Chip8_parser.parse_program_from_file filename in
    let program_bytes = Assembler.assemble parsed_program in
    save_to_file program_bytes;
    true
  with
  | Parser_error.Chip8ParserException exn ->
    Assembler_error.print_parser_error_in_file exn filename;
    false
  | Assembler_error.Chip8AsmException exn ->
    Assembler_error.print_assembler_error_in_file exn filename;
    false

let main =
  if Array.length Sys.argv = 1 then
    (Arg.usage speclist (Sys.argv.(0) ^ usage_msg); false)
  else
    if parse_argv () then assemble !input_file else false

let () =
    if not main then exit 1
    else exit 0
