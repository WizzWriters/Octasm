open Syntax

type label_description = { offset: int }

let labels = Hashtbl.create 10

let collect_labels_from_code_block offset (code_block: instruction_block) =
  let label_name = code_block.label.value in
  let instructions_size = List.length code_block.instructions * 2 in
  if Hashtbl.mem labels label_name then
    Assembler_error.throw @@
      Assembler_error.SymbolRedefinition code_block.label
  else
    Hashtbl.add labels label_name { offset };
    offset + instructions_size

let get_sprite_size value =
  match value with
  | NumberList num_list -> List.length num_list

let collect_labels_from_value_def offset (value_def: value_definition) =
  let value_name = value_def.label.value in
  let value_size =
    match value_def.typename.value with
    | "sprite" -> get_sprite_size value_def.value
    | _ -> Assembler_error.throw @@
      Assembler_error.UknownType value_def.typename
    in
  if Hashtbl.mem labels value_name then
    Assembler_error.throw @@ Assembler_error.SymbolRedefinition value_def.label
  else
    Hashtbl.add labels value_name { offset };
    offset + value_size

let collect_labels_from_directive offset directive =
  match directive with
  | Text instructions ->
    List.fold_left collect_labels_from_code_block offset instructions
  | Data value_defs ->
    let final_offset =
      List.fold_left collect_labels_from_value_def offset value_defs in
    if final_offset mod 2 = 0 then final_offset else final_offset + 1

let get_starting_offset () =
  if !Options.no_entry_point then 0x200 else 0x202

let collect_labels program =
  let starting_offset = get_starting_offset () in
  List.fold_left collect_labels_from_directive starting_offset program
  - starting_offset

let get_label_description label_name =
  Hashtbl.find_opt labels label_name

let reset_labels () =
  Hashtbl.reset labels
