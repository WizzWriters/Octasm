open Syntax
open Utils

let nullary_instruction_list = [
  ("cls", fun () -> [ 0x00; 0xE0 ]);
  ("ret", fun () -> [ 0x00; 0xEE ])
]

let nullary_instructions_lookup_table =
  Hashtbl.create @@ List.length nullary_instruction_list

let () = fill_hashtbl nullary_instructions_lookup_table nullary_instruction_list

let encode buffer pos (instruction: string expression) =
  let instruction_name = instruction.value in
  match Hashtbl.find_opt nullary_instructions_lookup_table instruction_name with
  | Some encode_callback ->
    let instruction_code =
      encode_callback () |> bytes_of_int_list in
    let instruction_code_length =
      write_instruction_code buffer pos instruction_code in
    (buffer, pos + instruction_code_length)
  | None -> Assembler_error.throw @@
    Assembler_error.UknownInstruction instruction
