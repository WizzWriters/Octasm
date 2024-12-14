open Syntax
open Encoder
open Assembler_utils

let create_program_buffer program_size = (Bytes.create program_size, 0)

let create_program_buffer_with_start_jump program_size =
  let buffer, position = create_program_buffer (program_size + 2) in
  let start_label = create_dummy_expression "_start" in
  let call_instruction =
    create_instruction "jp" [NameRefExpr start_label] in
  encode_instruction (buffer, position) call_instruction

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

let encode program_size program =
  let buffer, position =
    if !Options.no_entry_point
      then create_program_buffer program_size
      else create_program_buffer_with_start_jump program_size in
  let (encoded, _) =
    List.fold_left encode_directive (buffer, position) program in
  encoded

let assemble program =
  let program_size = Labels.collect_labels program in
  let result = encode program_size program in
  Labels.reset_labels ();
  result
