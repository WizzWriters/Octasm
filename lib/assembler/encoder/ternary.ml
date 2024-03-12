open Utils
open Syntax
open Assembler_utils

let get_registers_for_drw_instruction reg1_expr reg2_expr =
  let register1 = get_register_from_register_expr reg1_expr in
  let register2 = get_register_from_register_expr reg2_expr in
  match register1, register2 with
  | GeneralPurpose regnum1, GeneralPurpose regnum2 ->
    (regnum1, regnum2)
  | GeneralPurpose _, _ ->
    Assembler_error.throw @@ Assembler_error.BadRegister reg2_expr
  | _, _ ->
    Assembler_error.throw @@ Assembler_error.BadRegister reg1_expr

let encode_drw_instruction arg1 arg2 arg3 =
  match arg1, arg2, arg3 with
  | RegisterExpr reg1_expr, RegisterExpr reg2_expr, ConstExpr const_expr ->
    let (regnum1, regnum2) =
      get_registers_for_drw_instruction reg1_expr reg2_expr in
    let byte = const_expr.value in
    if check_4bit_bounds byte then
      [0xD0 lor regnum1; (regnum2 lsl 4) lor byte]
    else
      Assembler_error.throw @@ Assembler_error.ValueOutOfBounds const_expr
  | RegisterExpr _, RegisterExpr _, _ ->
    Assembler_error.throw @@ Assembler_error.TypeError arg3
  | RegisterExpr _, _, _ ->
    Assembler_error.throw @@ Assembler_error.TypeError arg2
  | _, _, _ ->
    Assembler_error.throw @@ Assembler_error.TypeError arg1

let ternary_instruction_list = [
  "drw", encode_drw_instruction
]

let ternary_instruction_lookup_table =
  Hashtbl.create @@ List.length ternary_instruction_list

let () = fill_hashtbl ternary_instruction_lookup_table ternary_instruction_list

let encode buffer pos (instruction: string expression) arg1 arg2 arg3 =
  let instruction_name = instruction.value in
  match Hashtbl.find_opt ternary_instruction_lookup_table instruction_name with
  | Some encode_callback ->
    let instruction_code =
      encode_callback arg1 arg2 arg3 |> bytes_of_int_list in
    let instruction_code_length =
      write_instruction_code buffer pos instruction_code in
    (buffer, pos + instruction_code_length)
  | None -> Assembler_error.throw @@
    Assembler_error.UknownInstruction instruction
