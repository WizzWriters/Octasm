open Syntax
open Utils
open Assembler_utils

let get_register_expr argument =
  match argument with
  | RegisterExpr register_expr -> register_expr
  | _ -> Assembler_error.throw @@ Assembler_error.TypeError argument

let encode_syscall_instruction arg_expr =
  let argument_value = get_address_value arg_expr in
  let upper, lower = split_int argument_value in
  [upper; lower]

let encode_jump_instruction arg_expr =
  let argument_value = get_address_value arg_expr in
  let upper, lower = split_int argument_value in
  [upper lor 0x10; lower]

let encode_call_instruction arg_expr =
  let argument_value = get_address_value arg_expr in
  let upper, lower = split_int argument_value in
  [upper lor 0x20; lower]

let encode_general_purpose_register_instruction arg_expr callback =
  let register_expr = get_register_expr arg_expr in
  match get_register_from_register_expr register_expr with
  | GeneralPurpose x -> callback x
  | _ -> Assembler_error.throw @@ Assembler_error.BadRegister register_expr

let encode_shift_right_instruction arg_expr =
  encode_general_purpose_register_instruction arg_expr
  (fun x -> [ 0x80 lor x; (x lsl 4) lor 0x06 ])

let encode_shift_left_instruction arg_expr =
  encode_general_purpose_register_instruction arg_expr
  (fun x -> [ 0x80 lor x; (x lsl 4) lor 0x0E ])

let encode_skip_instruction arg_expr =
  encode_general_purpose_register_instruction arg_expr
  (fun x -> [ 0xE0 lor x; 0x9E ])

let encode_do_not_skip_instruction arg_expr =
  encode_general_purpose_register_instruction arg_expr
  (fun x -> [ 0xE0 lor x; 0xA1 ])

let unary_instruction_list = [
  ("sys", encode_syscall_instruction);
  ("jp", encode_jump_instruction);
  ("call", encode_call_instruction);
  ("shr", encode_shift_right_instruction);
  ("shl", encode_shift_left_instruction);
  ("skp", encode_skip_instruction);
  ("sknp", encode_do_not_skip_instruction)
]

let unary_instruction_lookup_table =
  Hashtbl.create @@ List.length unary_instruction_list

let () = fill_hashtbl unary_instruction_lookup_table unary_instruction_list

let encode buffer pos (instruction: string expression) argument =
  let instruction_name = instruction.value in
  match Hashtbl.find_opt unary_instruction_lookup_table instruction_name with
  | Some encode_callback ->
    let instruction_code =
      encode_callback argument |> bytes_of_int_list in
    let instruction_code_length =
      write_instruction_code buffer pos instruction_code in
    (buffer, pos + instruction_code_length)
  | None -> Assembler_error.throw @@
    Assembler_error.UknownInstruction instruction
