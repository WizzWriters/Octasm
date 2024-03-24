open Syntax
open Encoder

let encode_instruction_block (buffer, position) instruction_block =
  let instructions = instruction_block.instructions in
  List.fold_left encode_instruction (buffer, position) instructions

let encode_directive (buffer, position) program =
  match program with
  | Text instruction_block ->
    List.fold_left encode_instruction_block (buffer, position) instruction_block
  | Data definition_list ->
    let (new_buffer, new_position) =
    List.fold_left encode_definition (buffer, position) definition_list in
    maybe_add_padding (new_position - position) new_buffer new_position

let encode buffer program =
  let (encoded, _) = List.fold_left encode_directive (buffer, 0) program in
  encoded

let assemble program =
  let program_size = Labels.collect_labels program in
  let result = encode (Bytes.create program_size) program in
  Labels.reset_labels ();
  result
