type argument =
  | Const of int
  | NameRef of string
  | Register of string

type value = int
type value_definition = { name:string; typename: string; value:value list }

type instruction_name = string

type instruction =
  | NullaryInstruction of instruction_name
  | UnaryInstruction of instruction_name * argument
  | BinaryInstruction of instruction_name * argument * argument

type instruction_block = { label:string; instructions:instruction list }

type directive =
  | Text of instruction_block list
  | Data of value_definition list

type program = directive list
