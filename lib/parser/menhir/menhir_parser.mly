%{
open Syntax
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
    { {label = label; instructions = instructions} }
  ;

instruction:
  | opname = NAME { NullaryInstruction opname }
  | opname = NAME; arg = argument { UnaryInstruction (opname, arg) }
  | opname = NAME; arg1 = argument; COMMA; arg2 = argument
    { BinaryInstruction (opname, arg1, arg2) }
  ;

argument:
  | number = NUMBER { Const number }
  | name_ref = NAME_REF { NameRef name_ref }
  | register = REGISTER { Register register }
  ;

value_definition:
  | name = LABEL; tname = TYPENAME;
    value = separated_nonempty_list(COMMA, value)
    { { name = name; typename = tname; value = value } }
  ;

value:
  | num = NUMBER { num }
  ;
