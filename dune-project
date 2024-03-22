(lang dune 3.14)
(using menhir 3.0)

(name octasm)

(generate_opam_files true)

(source
 (github WizzWriters/Octasm))

(authors "Cezary Świtała")

(maintainers "Cezary Świtała")

(license MIT)

; (documentation https://url/to/documentation)

(package
 (name octasm)
 (synopsis "CHIP8 Assembler")
 (description "CHIP8 assembler with syntax inspired by GNU Asssembler.")
 (depends ocaml dune menhir))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
