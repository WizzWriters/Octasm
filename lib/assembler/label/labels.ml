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

let collect_labels_from_directive start_offset directive =
  match directive with
  | Text instructions ->
    List.fold_left collect_labels_from_code_block start_offset instructions
  | Data _ -> raise Exit

let collect_labels program =
  let starting_offset = 0x200 in
  List.fold_left collect_labels_from_directive starting_offset program
  - starting_offset

let get_label_description label_name =
  Hashtbl.find_opt labels label_name

let reset_labels () =
  Hashtbl.reset labels
