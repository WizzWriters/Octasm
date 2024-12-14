# Switches between two sprites every second

.text
    wait_second: # waits exactly one second
        ld %v3, $60
        ld %dt, %v3
    wait_loop:
        ld %v3, %dt
        sne %v3, $0
        ret
        jp $wait_loop

    _start:
        ld %v0, $0
        ld %v1, $0
    main_loop:
        cls
        ld %i, $sprite1
        drw %v0, %v1, $5
        call $wait_second

        cls
        ld %i, $sprite2
        drw %v0, %v1, $5
        call $wait_second

        jp $main_loop

.data
    sprite1:
        .sprite
            $0b10101000,
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
