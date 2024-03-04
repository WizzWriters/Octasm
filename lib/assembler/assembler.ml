open Syntax

let encode_instruction_block (buffer, position) instruction_block =
  let instructions = instruction_block.instructions in
  List.fold_left Encoder.encode_instruction (buffer, position) instructions

let encode_directive (buffer, position) program =
  match program with
  | Text instruction_block ->
    List.fold_left encode_instruction_block (buffer, position) instruction_block
  | Data _ -> raise Exit

let encode buffer program =
  let (encoded, _) = List.fold_left encode_directive (buffer, 0) program in
  encoded

let assemble program =
  let program_size = Labels.collect_labels program in
  let result = encode (Bytes.create program_size) program in
  Labels.reset_labels ();
  result
