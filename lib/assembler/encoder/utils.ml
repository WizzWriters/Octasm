let safe_char_of_int x = try char_of_int x with
  | Invalid_argument _ -> Assembler_error.throw @@
    Assembler_error.InternalError ("Bad instruction size. " ^ (string_of_int x))

let bytes_of_int_list int_list =
  let byte_list = List.map safe_char_of_int int_list in
  let bytes = Bytes.create @@ List.length byte_list in
  List.iteri (fun i x ->  Bytes.set bytes i x) byte_list;
  bytes

let write_instruction_code buffer pos instruction_code =
  let instruction_code_length = Bytes.length instruction_code in
  Bytes.blit instruction_code 0 buffer pos instruction_code_length;
  instruction_code_length

let fill_hashtbl hashtbl list = List.iter
  (fun (elem, callback) -> Hashtbl.add hashtbl elem callback)
  list

let split_int number = (number lsr 8, number land 0xff)
