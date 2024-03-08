type register =
  | GeneralPurpose of int
  | LongRegister
  | DelayTimerRegister
  | SoundTimerRegister

let get_label_offset (label: Syntax.label_name) =
  match Labels.get_label_description label.value with
  | Some label_info -> label_info.offset
  | None -> Assembler_error.throw @@ Assembler_error.UndefinedReference label

let check_12bit_bounds number = number >= 0 && number <= 0xfff
let check_byte_bounds number = number >= 0 && number <= 0xff
let check_register_bounds number = number >= 0 && number <= 15

let reg_number_of_hex_char c = int_of_string_opt ("0x" ^ Char.escaped c)

let get_general_purpose_register register_str =
  Scanf.sscanf register_str "v%c" reg_number_of_hex_char

let get_register_from_register_expr (reg_expr: string Syntax.expression) =
  let register_str = reg_expr.value in
  match register_str with
  | "i"  -> LongRegister
  | "dt" -> DelayTimerRegister
  | "st" -> SoundTimerRegister
  | _    ->
    begin match get_general_purpose_register register_str with
    | Some x when check_register_bounds x -> GeneralPurpose x
    | Some _ | None ->
      Assembler_error.throw @@ Assembler_error.UknownRegister reg_expr
    end
