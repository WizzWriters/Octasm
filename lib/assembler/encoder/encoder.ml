open Syntax
open List

let encode_instruction (buffer, pos) (instruction: instruction) =
  let name, arguments = instruction in
  match List.length arguments with
  | 0 -> Nullary.encode buffer pos name
  | 1 -> Unary.encode buffer pos name (nth arguments 0)
  | 2 -> Binary.encode buffer pos name (nth arguments 0) (nth arguments 1)
  | 3 ->
    Ternary.encode buffer pos name
      (nth arguments 0) (nth arguments 1) (nth arguments 2)
  | _ -> Assembler_error.throw @@ Assembler_error.UknownInstruction name
