open Syntax
open Assembler_utils
open Utils

let encode_reg_byte_instruction reg_expr (byte_expr: int expression) callback =
  let register = get_register_from_register_expr reg_expr in
  match register with
  | GeneralPurpose regnum ->
    if check_byte_bounds byte_expr.value then callback regnum byte_expr.value
    else Assembler_error.throw @@ Assembler_error.ValueOutOfBounds byte_expr
  | _ -> Assembler_error.throw @@ Assembler_error.BadRegister reg_expr

let encode_reg_reg_instruction reg1_expr reg2_expr callback =
  let register1 = get_register_from_register_expr reg1_expr in
  let register2 = get_register_from_register_expr reg2_expr in
  match (register1, register2) with
  | GeneralPurpose regnum1, GeneralPurpose regnum2 -> callback regnum1 regnum2
  | GeneralPurpose _, _ ->
    Assembler_error.throw @@ Assembler_error.BadRegister reg2_expr
  | _,_ ->
    Assembler_error.throw @@ Assembler_error.BadRegister reg1_expr

let encode_skip_eq_instruction arg1 arg2 =
  match arg1, arg2 with
  | RegisterExpr reg_expr, ConstExpr const_expr ->
    let encode_skip_eq reg byte = [0x30 lor reg; byte] in
    encode_reg_byte_instruction reg_expr const_expr encode_skip_eq
  | RegisterExpr reg1_expr, RegisterExpr reg2_expr ->
    let encode_skip_eq reg1 reg2 = [0x50 lor reg1; reg2 lsl 4] in
    encode_reg_reg_instruction reg1_expr reg2_expr encode_skip_eq
  | RegisterExpr _, _ ->
    Assembler_error.throw @@ Assembler_error.TypeError arg2
  | _,_ ->
    Assembler_error.throw @@ Assembler_error.TypeError arg2

let encode_skip_neq_instruction arg1 arg2 =
  match arg1, arg2 with
  | RegisterExpr reg_expr, ConstExpr const_expr ->
    let encode_skip_neq reg byte = [0x40 lor reg; byte] in
    encode_reg_byte_instruction reg_expr const_expr encode_skip_neq
  | RegisterExpr reg1_expr, RegisterExpr reg2_expr ->
    let encode_skip_neq reg1 reg2 = [0x90 lor reg1; reg2 lsl 4] in
    encode_reg_reg_instruction reg1_expr reg2_expr encode_skip_neq
  | RegisterExpr _, _ ->
    Assembler_error.throw @@ Assembler_error.TypeError arg2
  | _,_ ->
    Assembler_error.throw @@ Assembler_error.TypeError arg1

let encode_arythmetic_instruction inst_number arg1 arg2 =
  match arg1, arg2 with
  | RegisterExpr reg1_expr, RegisterExpr reg2_expr ->
    let encode reg1 reg2 = [0x80 lor reg1; (reg2 lsl 4) lor inst_number] in
    encode_reg_reg_instruction reg1_expr reg2_expr encode
  | RegisterExpr _, _ ->
    Assembler_error.throw @@ Assembler_error.TypeError arg2
  | _,_ ->
    Assembler_error.throw @@ Assembler_error.TypeError arg1

let encode_or_instruction = encode_arythmetic_instruction 0x01
let encode_and_instruction = encode_arythmetic_instruction 0x02
let encode_xor_instruction = encode_arythmetic_instruction 0x03
let encode_sub_instruction = encode_arythmetic_instruction 0x05
let encode_subn_instruction = encode_arythmetic_instruction 0x07

let encode_add_reg_reg_instruction reg1_expr reg2_expr =
  let register1 = get_register_from_register_expr reg1_expr in
  let register2 = get_register_from_register_expr reg2_expr in
  match register1, register2 with
  | GeneralPurpose regnum1, GeneralPurpose regnum2 ->
    [0x80 lor regnum1; (regnum2 lsl 4) lor 0x04]
  | LongRegister, GeneralPurpose regnum ->
    [0xF0 lor regnum; 0x1E]
  | LongRegister, _ | GeneralPurpose _, _ ->
    Assembler_error.throw @@ Assembler_error.BadRegister reg2_expr
  | _,_ ->
    Assembler_error.throw @@ Assembler_error.BadRegister reg1_expr

let encode_add_instruction arg1 arg2 =
  match arg1, arg2 with
  | RegisterExpr reg_expr, ConstExpr const_expr ->
    let encode_add reg byte = [0x70 lor reg; byte] in
    encode_reg_byte_instruction reg_expr const_expr encode_add
  | RegisterExpr reg1_expr, RegisterExpr reg2_expr ->
    encode_add_reg_reg_instruction reg1_expr reg2_expr
  | RegisterExpr _, _ ->
    Assembler_error.throw @@ Assembler_error.TypeError arg2
  | _,_ ->
    Assembler_error.throw @@ Assembler_error.TypeError arg1

let binary_instruction_list = [
  ("se", encode_skip_eq_instruction);
  ("sne", encode_skip_neq_instruction);
  ("or", encode_or_instruction);
  ("and", encode_and_instruction);
  ("xor", encode_xor_instruction);
  ("add", encode_add_instruction);
  ("sub", encode_sub_instruction);
  ("subn", encode_subn_instruction)
]

let binary_instruction_lookup_table =
  Hashtbl.create @@ List.length binary_instruction_list

let () = fill_hashtbl binary_instruction_lookup_table binary_instruction_list

let encode buffer pos (instruction: string expression) argument1 argument2 =
  let instruction_name = instruction.value in
  match Hashtbl.find_opt binary_instruction_lookup_table instruction_name with
  | Some encode_callback ->
    let instruction_code =
      encode_callback argument1 argument2 |> bytes_of_int_list in
    let instruction_code_length =
      write_instruction_code buffer pos instruction_code in
    (buffer, pos + instruction_code_length)
  | None -> Assembler_error.throw @@
    Assembler_error.UknownInstruction instruction
