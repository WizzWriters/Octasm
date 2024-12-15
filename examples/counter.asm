# Displays digits from 0 to 9 in a loop

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
