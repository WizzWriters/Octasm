(lang dune 3.14)
(using menhir 3.0)

(name chip_8_assembler)

(generate_opam_files true)

(source
 (github WizzWriters/chip8-assembler))

(authors "Cezary Świtała")

(maintainers "Cezary Świtała")

(license MIT)

; (documentation https://url/to/documentation)

(package
 (name chip_8_assembler)
 (synopsis "Assembler for CHIP8")
 (description "Assembler for CHIP8")
 (depends ocaml dune))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
