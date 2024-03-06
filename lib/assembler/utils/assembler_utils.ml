let get_label_offset (label: Syntax.label_name) =
  match Labels.get_label_description label.value with
  | Some label_info -> label_info.offset
  | None -> Assembler_error.throw @@ Assembler_error.UndefinedReference label

let check_12bit_bounds number = number >= 0 && number <= 0xfff
