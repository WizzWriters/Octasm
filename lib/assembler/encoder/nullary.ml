open Syntax

let nullary_instruction_list = [
  "cls", fun () -> [ 0x00; 0xE0 ]
]

let nullary_instructions_lookup_table =
  Hashtbl.create @@ List.length nullary_instruction_list

let fill hashtbl list = List.iter
  (fun (elem, callback) -> Hashtbl.add hashtbl elem callback)
  list

let () =
  fill nullary_instructions_lookup_table nullary_instruction_list

let bytes_of_int_list int_list =
  let byte_list = List.map (fun x -> char_of_int x) int_list in
  let bytes = Bytes.create @@ List.length byte_list in
  List.iteri (fun i x ->  Bytes.set bytes i x) byte_list;
  bytes

let encode buffer pos (instruction: string expression) =
  let instruction_name = instruction.value in
  if not @@ Hashtbl.mem nullary_instructions_lookup_table instruction_name then
    Assembler_error.throw @@ Assembler_error.UknownInstruction instruction
  else
    let encode_callback =
      Hashtbl.find nullary_instructions_lookup_table instruction_name in
    let instruction_code = encode_callback () |> bytes_of_int_list in
    let instruction_code_length = Bytes.length instruction_code in
    Bytes.blit instruction_code 0 buffer pos instruction_code_length;
    (buffer, pos + instruction_code_length)
