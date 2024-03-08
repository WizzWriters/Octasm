open Syntax

let encode_instruction (buffer, pos) instruction =
  match instruction with
  | NullaryInstruction name -> Nullary.encode buffer pos name
  | UnaryInstruction (name, arg) -> Unary.encode buffer pos name arg
  | BinaryInstruction (name, arg1, arg2) ->
    Binary.encode buffer pos name arg1 arg2
