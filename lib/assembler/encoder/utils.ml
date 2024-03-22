open Syntax

let safe_char_of_int x = try char_of_int x with
  | Invalid_argument _ -> Assembler_error.throw @@
    Assembler_error.InternalError ("Bad instruction size. " ^ (string_of_int x))

let bytes_of_int_list int_list =
  let byte_list = List.map safe_char_of_int int_list in
  let bytes = Bytes.create @@ List.length byte_list in
  List.iteri (fun i x ->  Bytes.set bytes i x) byte_list;
  bytes

let paste_bytes buffer pos bytes =
  let bytes_length = Bytes.length bytes in
  Bytes.blit bytes 0 buffer pos bytes_length;
  bytes_length

let write_instruction_code buffer pos instruction_code =
  paste_bytes buffer pos instruction_code

let fill_hashtbl hashtbl list = List.iter
  (fun (elem, callback) -> Hashtbl.add hashtbl elem callback)
  list

let split_int number = (number lsr 8, number land 0xff)

let int_list_of_int_expression_list (int_expr_list: int expression list) =
  List.map (fun (int_expr: int expression) -> int_expr.value) int_expr_list
