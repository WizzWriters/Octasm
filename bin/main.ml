let usage_msg = "chip8_asm <input_file> -o <output_file>"

let input_file = ref ""
let output_file = ref ""

let anon_fun filename =
  if input_file.contents = "" then
    input_file := filename
  else
    Assembler_error.throw @@
      ArgumentError ("Multiple input files specified.")

let speclist = [
  ("-o", Arg.Set_string output_file, "Set output file name")
]

let parse_argv () =
  try
    Arg.parse speclist anon_fun usage_msg;
    true
  with
  | Assembler_error.Chip8AsmException error ->
    print_endline ("Error: " ^ Assembler_error.string_of_error error);
    false

let assemble filename =
  if filename = "" then
    (print_endline "Input file not provided"; false)
  else try
    let parsed_program = Chip8_parser.parse_program_from_file filename in
    let _ = Assembler.assemble parsed_program in
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
    (Arg.usage speclist usage_msg; false)
  else
    if parse_argv () then assemble !input_file else false

let () =
    if not main then exit 1
    else exit 0
