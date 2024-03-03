open Syntax

type label_description = { offset: int }

let labels = Hashtbl.create 10

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

let collect_labels_from_code_block offset (code_block: instruction_block) =
  let label_name = code_block.label.value in
  let instructions_size = List.length code_block.instructions * 2 in
  if Hashtbl.mem labels label_name then
    Assembler_error.throw @@
      Assembler_error.SymbolRedefinition code_block.label
  else
    Hashtbl.add labels label_name { offset };
    offset + instructions_size

let collect_labels_from_directive start_offset directive =
  match directive with
  | Text instructions ->
    List.fold_left collect_labels_from_code_block start_offset instructions
  | Data _ -> raise Exit

let collect_labels (program: parsed_program) =
  let starting_offset = 0x200 in
  List.fold_left collect_labels_from_directive starting_offset program
  - starting_offset

let bytes_of_int_list int_list =
  let byte_list = List.map (fun x -> char_of_int x) int_list in
  let bytes = Bytes.create @@ List.length byte_list in
  List.iteri (fun i x ->  Bytes.set bytes i x) byte_list;
  bytes

let encode_nullary_instruction buffer pos (instruction: string expression) =
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

let encode_instruction (buffer, position) instruction =
  match instruction with
  | NullaryInstruction instruction ->
      encode_nullary_instruction buffer position instruction
  | _ -> raise Exit

let encode_instruction_block (buffer, position) instruction_block =
  let instructions = instruction_block.instructions in
  List.fold_left encode_instruction (buffer, position) instructions

let encode_directive (buffer, position) program =
  match program with
  | Text instruction_block ->
    List.fold_left encode_instruction_block (buffer, position) instruction_block
  | Data _ -> raise Exit

let encode buffer program =
  let (encoded, _) = List.fold_left encode_directive (buffer, 0) program in
  encoded

let assemble program =
  let program_size = collect_labels program in
  (* Printf.printf "Size: %d\n" program_size; *)
  encode (Bytes.create program_size) program
