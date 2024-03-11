%{
open Syntax

let wrap value location =
  let (start_p, end_p) = location in
  { start_p; end_p; value }
%}

%token <string> NAME
%token <string> NAME_REF
%token <string> LABEL
%token <string> TYPENAME
%token <int> NUMBER
%token <string> REGISTER

%token COMMA
%token L_PARENTHESES
%token R_PARENTHESES
%token EOF

%token DIRECTIVE_TEXT
%token DIRECTIVE_DATA

%start <Syntax.parsed_program> program

%%

program:
  | blocks = directive_block*; EOF { blocks }
  ;

directive_block:
  | DIRECTIVE_TEXT; text_blocks = instruction_block+ { Text text_blocks }
  | DIRECTIVE_DATA; value_defs = value_definition+ { Data value_defs }
  ;

instruction_block:
  | label = LABEL; instructions = instruction+
    { { label = wrap label $loc(label); instructions } }
  ;

instruction:
  | opname = NAME; arguments = separated_list(COMMA, argument)
    { (wrap opname $loc(opname), arguments) }
  ;

argument:
  | number = NUMBER { ConstExpr (wrap number $loc) }
  | name_ref = NAME_REF { NameRefExpr (wrap name_ref $loc) }
  | register = REGISTER { RegisterExpr (wrap register $loc) }
  | L_PARENTHESES; register = REGISTER; R_PARENTHESES
    { IndirectRefExpr (wrap register $loc) }
  ;

value_definition:
  | name = LABEL; tname = TYPENAME;
    value = separated_nonempty_list(COMMA, value)
    {{ name = wrap name $loc(name); typename = wrap tname $loc(tname); value }}
  ;

value:
  | num = NUMBER { NumberExpr (wrap num $loc) }
  ;
