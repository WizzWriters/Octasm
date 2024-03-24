open Syntax
open Utils
open Assembler_utils

let validate_sprite_byte (int_expr: int expression) =
  if not @@ check_byte_bounds int_expr.value then
    Assembler_error.throw @@
      Assembler_error.ValueOutOfBounds int_expr
  else ()

let validate_sprite_bytelist typename byte_list =
  if List.length byte_list > 15 then
    Assembler_error.throw @@
      Assembler_error.InvalidValueDefinition (typename, "To many bytes given.")
  else
    List.iter validate_sprite_byte byte_list; ()

let encode_sprite (buffer, pos) value_def =
  match value_def.value with
  | NumberList byte_expr_list ->
    validate_sprite_bytelist value_def.typename byte_expr_list;
    let byte_list = int_list_of_int_expression_list byte_expr_list in
    let bytes = bytes_of_int_list byte_list in
    let bytes_written = paste_bytes buffer pos bytes in
    (buffer, pos + bytes_written)
