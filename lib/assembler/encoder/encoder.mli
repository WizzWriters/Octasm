val encode_instruction: bytes * int -> Syntax.instruction -> bytes * int
val encode_definition: bytes * int -> Syntax.value_definition -> bytes * int
val maybe_add_padding: int -> bytes -> int -> bytes * int
