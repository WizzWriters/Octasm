open Syntax
open Utils

let create_sprite byte_list =
  let dummy_label = create_dummy_expression "dummy" in
  let dummy_typename = create_dummy_expression "sprite" in
  let byte_expr_list = List.map create_dummy_expression byte_list in
  let value = NumberList byte_expr_list in
  { label = dummy_label; typename = dummy_typename; value }

let test_encode_sprite sprite expected_bytes =
  let expected_size = List.length expected_bytes in
  let test_bytes = Bytes.create expected_size in
  let test_bytes, _ = Encoder.encode_definition (test_bytes, 0) sprite in
  compare_bytes_to_int_list test_bytes expected_bytes

let test_sprite_single_even () =
  let sprite_under_test = create_sprite [0xfa; 0xfb; 0xfc] in
  test_encode_sprite sprite_under_test [0xfa; 0xfb; 0xfc]

let test_data_list = [
  "sprite", test_sprite_single_even
]

let test_data (name, callback) =
  if callback () then true
  else begin
    print_endline @@ "Failed to encode " ^ name;
    false
  end

let test () =
  List.for_all test_data test_data_list
