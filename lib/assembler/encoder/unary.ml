open Syntax
open Utils

let encode_jump_instruction arg_expr =
  let argument_value =
    match arg_expr with
    | ConstExpr number -> number.value
    | NameRefExpr label -> get_label_offset label
    | _ -> Assembler_error.throw @@ Assembler_error.TypeError arg_expr
  in
  let (upper, lower) = split_12bit_int argument_value in
  [upper lor 0x10; lower]

let unary_instruction_list = [
  ("jp", encode_jump_instruction)
]

let unary_instruction_lookup_table =
  Hashtbl.create @@ List.length unary_instruction_list

let () = fill_hashtbl unary_instruction_lookup_table unary_instruction_list

let encode buffer pos (instruction: string expression) argument =
  let instruction_name = instruction.value in
  if not @@ Hashtbl.mem unary_instruction_lookup_table instruction_name then
    Assembler_error.throw @@ Assembler_error.UknownInstruction instruction
  else
    let encode_callback =
      Hashtbl.find unary_instruction_lookup_table instruction_name in
    let instruction_code = encode_callback argument |> bytes_of_int_list in
    let instruction_code_length =
      write_instruction_code buffer pos instruction_code in
    (buffer, pos + instruction_code_length)
