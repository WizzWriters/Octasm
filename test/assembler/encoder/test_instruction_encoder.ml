open Syntax
open Utils

let test_encode_instruction instruction expected_bytes =
  let test_bytes = Bytes.create 2 in
  let test_bytes, _ = Encoder.encode_instruction (test_bytes, 0) instruction in
  compare_bytes_to_int_list test_bytes expected_bytes

let test_sys_instruction () =
  let arguments = [ ConstExpr (create_dummy_expression 0xfff) ] in
  let instruction_under_test = create_instruction "sys" arguments in
  test_encode_instruction instruction_under_test [0x0F; 0xFF]

let test_cls_instruction () =
  let instruction_under_test = create_instruction "cls" [] in
  test_encode_instruction instruction_under_test [0x00; 0xE0]

let test_ret_instruction () =
  let instruction_under_test = create_instruction "ret" [] in
  test_encode_instruction instruction_under_test [0x00; 0xEE]

let test_jp_addr_instruction () =
  let arguments = [ConstExpr (create_dummy_expression 0xfff) ] in
  let instruction_under_test = create_instruction "jp" arguments in
  test_encode_instruction instruction_under_test [0x1f; 0xff]

let test_call_instruction () =
  let arguments = [ConstExpr (create_dummy_expression 0xfff) ] in
  let instruction_under_test = create_instruction "call" arguments in
  test_encode_instruction instruction_under_test [0x2f; 0xff]

let test_se_reg_byte_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
    ConstExpr (create_dummy_expression 0xff)
  ] in
  let instruction_under_test = create_instruction "se" arguments in
  test_encode_instruction instruction_under_test [0x3a; 0xff]

let test_sne_reg_byte_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
    ConstExpr (create_dummy_expression 0xff)
  ] in
  let instruction_under_test = create_instruction "sne" arguments in
  test_encode_instruction instruction_under_test [0x4a; 0xff]

let test_se_reg_reg_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
    RegisterExpr (create_dummy_expression "vb");
  ] in
  let instruction_under_test = create_instruction "se" arguments in
  test_encode_instruction instruction_under_test [0x5a; 0xb0]

let test_ld_reg_byte_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
    ConstExpr (create_dummy_expression 0xff)
  ] in
  let instruction_under_test = create_instruction "ld" arguments in
  test_encode_instruction instruction_under_test [0x6a; 0xff]

let test_add_reg_byte_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
    ConstExpr (create_dummy_expression 0xff)
  ] in
  let instruction_under_test = create_instruction "add" arguments in
  test_encode_instruction instruction_under_test [0x7a; 0xff]

let test_ld_reg_reg_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
    RegisterExpr (create_dummy_expression "vb");
  ] in
  let instruction_under_test = create_instruction "ld" arguments in
  test_encode_instruction instruction_under_test [0x8a; 0xb0]

let test_or_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
    RegisterExpr (create_dummy_expression "vb");
  ] in
  let instruction_under_test = create_instruction "or" arguments in
  test_encode_instruction instruction_under_test [0x8a; 0xb1]

let test_and_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
    RegisterExpr (create_dummy_expression "vb");
  ] in
  let instruction_under_test = create_instruction "and" arguments in
  test_encode_instruction instruction_under_test [0x8a; 0xb2]

let test_xor_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
    RegisterExpr (create_dummy_expression "vb");
  ] in
  let instruction_under_test = create_instruction "xor" arguments in
  test_encode_instruction instruction_under_test [0x8a; 0xb3]

let test_add_reg_reg_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
    RegisterExpr (create_dummy_expression "vb");
  ] in
  let instruction_under_test = create_instruction "add" arguments in
  test_encode_instruction instruction_under_test [0x8a; 0xb4]

let test_sub_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
    RegisterExpr (create_dummy_expression "vb");
  ] in
  let instruction_under_test = create_instruction "sub" arguments in
  test_encode_instruction instruction_under_test [0x8a; 0xb5]

let test_shr_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
  ] in
  let instruction_under_test = create_instruction "shr" arguments in
  test_encode_instruction instruction_under_test [0x8a; 0xa6]

let test_subn_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
    RegisterExpr (create_dummy_expression "vb");
  ] in
  let instruction_under_test = create_instruction "subn" arguments in
  test_encode_instruction instruction_under_test [0x8a; 0xb7]

let test_shl_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
  ] in
  let instruction_under_test = create_instruction "shl" arguments in
  test_encode_instruction instruction_under_test [0x8a; 0xaE]

let test_sne_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
    RegisterExpr (create_dummy_expression "vb");
  ] in
  let instruction_under_test = create_instruction "sne" arguments in
  test_encode_instruction instruction_under_test [0x9a; 0xb0]

let test_ld_longreg_addr_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "i");
    ConstExpr (create_dummy_expression 0xfff)
  ] in
  let instruction_under_test = create_instruction "ld" arguments in
  test_encode_instruction instruction_under_test [0xaf; 0xff]

let test_jp_zeroreg_addr_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "v0");
    ConstExpr (create_dummy_expression 0xfff)
  ] in
  let instruction_under_test = create_instruction "jp" arguments in
  test_encode_instruction instruction_under_test [0xbf; 0xff]

let test_rnd_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
    ConstExpr (create_dummy_expression 0xff)
  ] in
  let instruction_under_test = create_instruction "rnd" arguments in
  test_encode_instruction instruction_under_test [0xCa; 0xff]

let test_drw_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
    RegisterExpr (create_dummy_expression "vb");
    ConstExpr (create_dummy_expression 0xf)
  ] in
  let instruction_under_test = create_instruction "drw" arguments in
  test_encode_instruction instruction_under_test [0xDa; 0xbf]

let test_skp_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
  ] in
  let instruction_under_test = create_instruction "skp" arguments in
  test_encode_instruction instruction_under_test [0xEa; 0x9E]

let test_sknp_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
  ] in
  let instruction_under_test = create_instruction "sknp" arguments in
  test_encode_instruction instruction_under_test [0xEa; 0xA1]

let test_ld_reg_delay_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
    RegisterExpr (create_dummy_expression "dt");
  ] in
  let instruction_under_test = create_instruction "ld" arguments in
  test_encode_instruction instruction_under_test [0xFa; 0x07]

let test_ldk_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
  ] in
  let instruction_under_test = create_instruction "ldk" arguments in
  test_encode_instruction instruction_under_test [0xFa; 0x0A]

let test_ld_delay_reg_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "dt");
    RegisterExpr (create_dummy_expression "va");
  ] in
  let instruction_under_test = create_instruction "ld" arguments in
  test_encode_instruction instruction_under_test [0xFa; 0x15]

let test_ld_sound_reg_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "st");
    RegisterExpr (create_dummy_expression "va");
  ] in
  let instruction_under_test = create_instruction "ld" arguments in
  test_encode_instruction instruction_under_test [0xFa; 0x18]

let test_add_long_reg_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "i");
    RegisterExpr (create_dummy_expression "va");
  ] in
  let instruction_under_test = create_instruction "add" arguments in
  test_encode_instruction instruction_under_test [0xFa; 0x1E]

let test_lds_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
  ] in
  let instruction_under_test = create_instruction "lds" arguments in
  test_encode_instruction instruction_under_test [0xFa; 0x29]

let test_ldb_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
  ] in
  let instruction_under_test = create_instruction "ldb" arguments in
  test_encode_instruction instruction_under_test [0xFa; 0x33]

let test_ld_indirect_reg_instruction () =
  let arguments = [
    IndirectRefExpr (create_dummy_expression "i");
    RegisterExpr (create_dummy_expression "va");
  ] in
  let instruction_under_test = create_instruction "ld" arguments in
  test_encode_instruction instruction_under_test [0xFa; 0x55]

let test_ld_reg_indirect_instruction () =
  let arguments = [
    RegisterExpr (create_dummy_expression "va");
    IndirectRefExpr (create_dummy_expression "i");
  ] in
  let instruction_under_test = create_instruction "ld" arguments in
  test_encode_instruction instruction_under_test [0xFa; 0x65]

let test_instruction_list = [
  "cls", test_cls_instruction;
  "ret", test_ret_instruction;
  "sys <addr>", test_sys_instruction;
  "jp <addr>", test_jp_addr_instruction;
  "call <addr>", test_call_instruction;
  "se <reg> <byte>", test_se_reg_byte_instruction;
  "sne <reg> <byte>", test_sne_reg_byte_instruction;
  "se <reg> <reg>", test_se_reg_reg_instruction;
  "ld <reg> <byte>", test_ld_reg_byte_instruction;
  "add <reg> <byte>", test_add_reg_byte_instruction;
  "ld <reg> <reg>", test_ld_reg_reg_instruction;
  "or <reg> <reg>", test_or_instruction;
  "and <reg> <reg>", test_and_instruction;
  "xor <reg> <reg>", test_xor_instruction;
  "add <reg> <reg>", test_add_reg_reg_instruction;
  "sub <reg> <reg>", test_sub_instruction;
  "shr <reg>", test_shr_instruction;
  "subn <reg> <reg>", test_subn_instruction;
  "shl <reg>", test_shl_instruction;
  "sne <reg> <reg>", test_sne_instruction;
  "ld <long_reg> <addr>", test_ld_longreg_addr_instruction;
  "jp <zero_reg> <addr>", test_jp_zeroreg_addr_instruction;
  "rnd <reg> <byte>", test_rnd_instruction;
  "drw <reg> <reg> <nibble>", test_drw_instruction;
  "skp <reg>", test_skp_instruction;
  "sknp <reg>", test_sknp_instruction;
  "ld <reg> <delay>", test_ld_reg_delay_instruction;
  "ldk <reg>", test_ldk_instruction;
  "ld <delay> <reg>", test_ld_delay_reg_instruction;
  "ld <sound> <reg>", test_ld_sound_reg_instruction;
  "add <long_reg> <reg>", test_add_long_reg_instruction;
  "lds <reg>", test_lds_instruction;
  "ldb <reg>", test_ldb_instruction;
  "ld <indirect> <reg>", test_ld_indirect_reg_instruction;
  "ld <reg> <indirect>", test_ld_reg_indirect_instruction;
]

let test_instruction (instruction_name, callback) =
  if callback () then true
  else begin
    print_endline @@ "Failed to encode " ^ instruction_name ^ " instruction.";
    false
  end

let test () =
  List.for_all test_instruction test_instruction_list
