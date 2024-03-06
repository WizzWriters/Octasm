open Syntax

let encode_instruction (buffer, pos) instruction =
  match instruction with
  | NullaryInstruction name -> Nullary.encode buffer pos name
  | UnaryInstruction (name, arg) -> Unary.encode buffer pos name arg
  | _ -> raise Exit
