type 'a expression = {
  start_p: Lexing.position;
  end_p: Lexing.position;
  value: 'a
}

type argument =
  | ConstExpr of int expression
  | NameRefExpr of string expression
  | RegisterExpr of string expression

type value =
  | NumberExpr of int expression

type label_name = string expression
type type_name = string expression

type value_definition = {
  name:label_name;
  typename: type_name;
  value:value list
}

type instruction_name = string expression

type instruction =
  | NullaryInstruction of instruction_name
  | UnaryInstruction of instruction_name * argument
  | BinaryInstruction of instruction_name * argument * argument

type instruction_block = { label:label_name; instructions:instruction list }

type directive =
  | Text of instruction_block list
  | Data of value_definition list

type program = directive list
