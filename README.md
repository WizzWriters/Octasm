# Octasm - CHIP8 Assembler

Octasm is a low-level assembler for CHIP8 programs with syntax designed to
resemble that of the GNU Assembler.

## Example

The following example shows the basic syntax of this assembler. This program displays digits 0 to 9 in a loop.

```asm
.text                      # start code section
    wait_second:           # procedure that waits exactly one second
        ld %v3, $60
        ld %dt, %v3        # set the delay timer to 60
    wait_loop:
        ld %v3, %dt
        sne %v3, $0        # return if the delay timer is equal to 0
        ret
        jp $wait_loop

    _start:                # entry point of the program
        ld %v0, $0
        ld %v1, $0
        ld %v2, $0
    main_loop:
        cls
        lds %v2            # load the sprite of a digit
        drw %v0, %v1, $5   # draw the sprite
        call $wait_second  # wait for 1 second
        add %v2, $1        # increment the digit
        sne %v2, $10       # if 10 reached, go back to 0
        ld %v2, $0
        jp $main_loop
```

## Install and run the assembler

Assuming you have Ocaml environment set up with [dune](https://github.com/ocaml/dune?tab=readme-ov-file#installation-1) and [menhir](https://gallium.inria.fr/~fpottier/menhir/) packages installed, all you have to do is run:

```
$ dune build
$ dune install
```

Then you can start to compile assembly files to chip8 programs:

```
$ octasm ./examples/counter.asm
```

The result will be saved to `./examples/counter.ch8` by default, but you can control path to output file via `-o` option. Next you can run the program using any chip8 interpreter (for example, check out [Cadmium](https://games.gulrak.net/cadmium/)).

## Syntax description

Every program consists of a code and data sections. Code sections are defined using `.text` directive, and data sections are defined using `.data` directive.

### Code Sections

Every code section is made out of code blocks, that have label and a list of instructions:

```asm
.text                 # code section directive
    wait_second:      # label
        ld %v3, $60   # first instruction
        ld %dt, %v3   # second instruction
        # [...]
```

#### Labels

Labels are names followed by colon, for example `wait_second:`. They allow as to refer to parts of chip8 programs (instructions or sprites) without knowing their exact address in the actual program.

There is one special label called `_start` that indicates that this is an entry point to our program. It has to be present somewhere in the program.

(Note: This behaviour can be modified with `--no-entry-point` option. With it enabled the program will start at the beggining, even if the program starts with a data section, as this assembler does not move around any of the sections or instructions - use only when necessary!)

#### Instructions

Each instruction has a name and a list of arguments separated with commas (some have 0 arguments). Depending on the instruction, arguments can refer to general purpose registers, special registers, labels or constant values. Behaviour of an instruction can change depending on the type of arguments.

For example when writing `ld %v3, $60` we call instruction named `ld` with the first argument `%v3` and the second argument `$60`.

List of instructions will be presented in a table in the next chapter (List of instructions).

#### Arguments

There are three types of arguments: registers, constant values and references to a label.

When passing a register as an argument we add a `%` prefix. General purpose registers are reffered to as `%v0, %v1, ..., %vf`. Address register is denoted as `%i`, delay timer register as `%dt`, sound timer register as `%st`.

When passing constant value we start with `$` sign and follow it with a number. The number can be written either in a decimal `$2`, hexadecimal `$0x2` or binary `$0b10` form.

When refering to a label we also start with a `$` prefix and follow it with the name of the label. Upon compilation this will be changed to the actual address of this label in the resulting chip8 program. So for example `jp $wait_loop` will jump to the first instruction in `wait_loop` code block.

### Data Sections

Every data section is made out of definitions, that consist of label, type and value:

```asm
.data
    sprite1:               # this is a label of this value
        .sprite            # this is a type
            $0b10101000,   # sprite is written out as a list of bytes
            $0b01010000,
            $0b10101000,
            $0b01010000,
            $0b10101000

    sprite2:
        .sprite
            $0b01010000,
            $0b10101000,
            $0b01010000,
            $0b10101000,
            $0b01010000
```

Currently there is only a one value type: `sprite`. You can refer to sprites via labels. For example to load an address of the sprite with label `sprite2` to address register, you can write `ld %i, $sprite2`.


## List of instructions

Octasm currently supports full basic CHIP-8 instruction set. You can refer to the [instruction set](http://devernay.free.fr/hacks/chip8/C8TECH10.HTM) to check what those instructions do exactly. The table below shows how names used there map to syntax used in Octasm.

| Technical Reference | Octasm                | Short description                      |
| ------------------- | --------------------- | -------------------------------------- |
| SYS addr            | sys $addr             | Jump to a machine code routine.        |
| CLS                 | cls                   | Clear the display.                     |
| RET                 | ret                   | Return from a subroutine.              |
| JP addr             | jp $addr              | Jump to location $addr.                |
| CALL addr           | call $addr            | Call subroutine at $addr.              |
| SE Vx, byte         | se %vx, $byte         | Skip next instruction if %vx == $byte. |
| SNE Vx, byte        | sne %vx, $byte        | Skip next instruction if $vx != $byte. |
| SE Vx, Vy           | se %vx, %vy           | Skip next instruction if $vx == $vy.   |
| LD Vx, byte         | ld %vx, $byte         | Set %vx = $byte.                       |
| ADD Vx, byte        | add %vx, $byte        | Set %vx = %vx + $byte.                 |
| LD Vx, Vy           | ld %vx, %vy           | Set %vx = %vy.                         |
| OR Vx, Vy           | or %vx, %vy           | Set %vx = %vx \| %vy.                  |
| AND Vx, Vy          | and %vx, %vy          | Set %vx = %vx \& %vy.                  |
| XOR Vx, Vy          | xor %vx, %vy          | Set %vx = %vx \^ %vy.                  |
| ADD Vx, Vy          | add %vx, %vy          | Set %vx = %vx + %vy.                   |
| SUB Vx, Vy          | sub %vx, %vy          | Set %vx = %vx - %vy.                   |
| SHR Vx {, Vy}       | shr %vx               | Set %vx = %vx >> 1.                    |
| SUBN Vx, Vy         | subn %vx, %vy         | Set %vx = %vy - %vx.                   |
| SHL Vx {, Vy}       | shl %vx               | Set %vx = %vx << 1.                    |
| SNE Vx, Vy          | sne %vx, %vy          | Skip next instruction if $vx != $vy.   |
| LD I, addr          | ld %i, $addr          | Set %i = $addr.                        |
| JP V0, addr         | jp %v0, $addr         | Jump to location $addr + %v0.          |
| RND Vx, byte        | rnd %vx, $byte        | Set %vx = random_number \& $byte.      |
| DRW Vx, Vy, nibble  | drw %vx, %vy, $nibble | Draw a sprite.                         |
| SKP Vx              | skp %vx               | Skip instruction if key pressed.       |
| SKNP Vx             | sknp %vx              | Skip instruction if key not pressed.   |
| LD Vx, DT           | ld %vx, %dt           | Set %vx = delay timer value.           |
| LD Vx, K            | ldk %vx               | Wait for a key press and store it.     |
| LD DT, Vx           | ld %dt, %vx           | Set delay timer = %vx.                 |
| LD ST, Vx           | ld %st, %vx           | Set sound timer = %vx.                 |
| ADD I, Vx           | add %i, %vx           | Set %i = %i + %vx.                     |
| LD F, Vx            | lds %vx               | Set %i = sprite for digit %vx.         |
| LD B, Vx            | ldb %vx               | Get BCD representation of %vx          |
| LD [I], Vx          | ld (%i), %vx          | Store registers in memory.             |
| LD Vx, [I]          | ld %vx, (%i)          | Load registers from memory.            |
