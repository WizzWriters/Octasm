
let tests = [
  Test_instruction_encoder.test ();
  Test_data_encoder.test ()
]

let () =
  if List.for_all Fun.id tests then exit 0
  else exit 1