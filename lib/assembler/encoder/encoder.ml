open Syntax
open List
open Utils

let encode_instruction (buffer, pos) instruction =
  let name, arguments = instruction in
  match List.length arguments with
  | 0 -> Nullary.encode buffer pos name
  | 1 -> Unary.encode buffer pos name (nth arguments 0)
  | 2 -> Binary.encode buffer pos name (nth arguments 0) (nth arguments 1)
  | 3 ->
    Ternary.encode buffer pos name
      (nth arguments 0) (nth arguments 1) (nth arguments 2)
  | _ -> Assembler_error.throw @@ Assembler_error.UknownInstruction name

let maybe_add_padding bytes_written buffer pos =
  if bytes_written mod 2 <> 0 then
    let _ = paste_bytes buffer pos (bytes_of_int_list [0]) in
    (buffer, pos + 1)
  else (buffer, pos)

let encode_definition (buffer, pos) value_def =
  match value_def.typename.value with
  | "sprite" -> Sprite.encode_sprite (buffer, pos) value_def
  | _ ->  Assembler_error.throw @@ Assembler_error.UknownType value_def.typename
