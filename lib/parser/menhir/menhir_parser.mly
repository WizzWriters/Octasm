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
%token EOF

%token DIRECTIVE_TEXT
%token DIRECTIVE_DATA

%start <Syntax.program> program

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
  | opname = NAME { NullaryInstruction (wrap opname $loc) }
  | opname = NAME; arg = argument
    { UnaryInstruction (wrap opname $loc(opname), arg) }
  | opname = NAME; arg1 = argument; COMMA; arg2 = argument
    { BinaryInstruction (wrap opname $loc(opname), arg1, arg2) }
  ;

argument:
  | number = NUMBER { ConstExpr (wrap number $loc) }
  | name_ref = NAME_REF { NameRefExpr (wrap name_ref $loc) }
  | register = REGISTER { RegisterExpr (wrap register $loc) }
  ;

value_definition:
  | name = LABEL; tname = TYPENAME;
    value = separated_nonempty_list(COMMA, value)
    {{ name = wrap name $loc(name); typename = wrap tname $loc(tname); value }}
  ;

value:
  | num = NUMBER { NumberExpr (wrap num $loc) }
  ;
