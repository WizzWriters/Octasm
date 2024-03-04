type label_description = { offset: int }

val collect_labels: Syntax.parsed_program -> int
val get_label_description: string -> label_description option
val reset_labels: unit -> unit
