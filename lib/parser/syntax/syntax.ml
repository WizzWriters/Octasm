type 'a expression = {
  start_p: Lexing.position;
  end_p: Lexing.position;
  value: 'a
}

type argument =
  | ConstExpr of int expression
  | NameRefExpr of string expression
  | RegisterExpr of string expression
  | IndirectRefExpr of string expression

type value =
  | NumberList of int expression list

type label_name = string expression
type type_name = string expression

type value_definition = {
  label: label_name;
  typename: string expression;
  value: value
}

type instruction_name = string expression
type instruction = instruction_name * argument list
type instruction_block = { label:label_name; instructions:instruction list }

type directive =
  | Text of instruction_block list
  | Data of value_definition list

type parsed_program = directive list

let get_position_of_expression (exp: 'a expression) =
  let line_num = exp.start_p.pos_lnum in
  let start_column = exp.start_p.pos_cnum - exp.start_p.pos_bol in
  let end_column = exp.end_p.pos_cnum - exp.end_p.pos_bol in
  (line_num, start_column, end_column)

let get_location_of_argument argument =
  match argument with
  | ConstExpr expr -> (expr.start_p, expr.end_p)
  | NameRefExpr expr
  | RegisterExpr expr
  | IndirectRefExpr expr -> (expr.start_p, expr.end_p)
