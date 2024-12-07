.text

# waits exactly one second
wait:
  ld %v3, $60
  ld %v4, $0
  ld %dt, %v3
wait_loop:
  ld %v3, %dt
  sne %v3, %v4
  ret
  jp $wait_loop

_start:
  cls
  ld %v0, $0
  ld %v1, $0

# switches between sprites every second
main_loop:
  cls
  ld %i, $digit_0
  drw %v0, %v1, $5
  call $wait
  cls
  ld %i, $digit_1
  drw %v0, %v1, $5
  call $wait
  jp $main_loop

.data
digit_0:
  .sprite
    $0b11110000,
    $0b10010000,
    $0b10010000,
    $0b10010000,
    $0b11110000

digit_1:
  .sprite
    $0b00100000,
    $0b01100000,
    $0b00100000,
    $0b00100000,
    $0b01110000
