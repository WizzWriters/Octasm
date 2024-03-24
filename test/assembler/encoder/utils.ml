open Syntax

let create_dummy_expression value = {
  start_p = Lexing.dummy_pos;
  end_p = Lexing.dummy_pos;
  value = value
}

let create_instruction name arguments: instruction =
  create_dummy_expression name, arguments

let bytes_of_int_list int_list =
  let byte_list = List.map char_of_int int_list in
  let bytes = Bytes.create @@ List.length byte_list in
  List.iteri (fun i x ->  Bytes.set bytes i x) byte_list;
  bytes

let compare_bytes_to_int_list bytes byte_list =
  if Bytes.compare bytes @@ bytes_of_int_list byte_list = 0 then true
  else false
