open Syntax

let encode_instruction (buffer, pos) instruction =
  match instruction with
  | NullaryInstruction name -> Nullary.encode buffer pos name
  | _ -> raise Exit
