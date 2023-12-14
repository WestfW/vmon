#include "vmon/config.h"

.global print_hex_prefix
.global print_hex_addr
.global print_hex_word
.global print_hex_byte
.global print_ascii
.global print_string
.global print_decimal
.global print_star

.text

print_hex_prefix:
    # output prefix
    li      t1, '0'
    sb      t1, 0(s1)               # print to UART
    li      t1, 'x'
    sb      t1, 0(s1)               # print to UART
    ret

print_hex_addr:
    # print addr passed in a0 in hex
    addi    sp, sp, -(XLEN_BYTES*3)             
    SAVE_X    ra, 0(sp)
    SAVE_X    s2, (XLEN_BYTES*1)(sp)
    SAVE_X    a0, (XLEN_BYTES*2)(sp)
    # output prefix
	jal     ra, print_hex_prefix

    # split 64 bit into 32-bit words
    mv      s2, a0
    srli    a0, a0, 16
    srli    a0, a0, 16
#if XLEN >= 64
    jal     ra, print_hex_word
#endif
    mv      a0, s2
    jal     ra, print_hex_word

    LOAD_X     ra, 0(sp)             
    LOAD_X     s2, (XLEN_BYTES*1)(sp)
    LOAD_X     a0, (XLEN_BYTES*2)(sp)
    addi    sp, sp, (XLEN_BYTES*3)
    ret


print_hex_word:
    # in: word in a0
    # out: word in a0
    addi    sp, sp, -(XLEN_BYTES*3)           
    SAVE_X    ra, 0(sp)
    SAVE_X    s2, (XLEN_BYTES*1)(sp)
    SAVE_X    a0, (XLEN_BYTES*2)(sp)
    li      t0, 0xffffffff
    and     s2, a0, t0              # save lower 32 bits
    srli    a0, s2, 24
    jal     ra, print_hex_byte
    srli    a0, s2, 16
    andi    a0, a0, 0xff
    jal     ra, print_hex_byte
    srli    a0, s2, 8
    andi    a0, a0, 0xff
    jal     ra, print_hex_byte
    andi    a0, s2, 0xff
    jal     ra, print_hex_byte
    LOAD_X     ra, 0(sp)             
    LOAD_X     s2, (XLEN_BYTES*1)(sp)               
    LOAD_X     a0, (XLEN_BYTES*2)(sp)               
    addi    sp, sp, (XLEN_BYTES*3)
    ret


print_hex_byte:
    # print byte passed in a0 in hex
    mv      a1, a0                  # duplicate a0 for later
    li      a2, 10
    # left nibble
    and     a0, a0, 0x000000f0
    srli    a0, a0, 4
    blt     a0, a2, print_hex_byte_is_digit
    add     a0, a0, 7+32           
print_hex_byte_is_digit:
    add     a0, a0, 0x30           
    sb      a0, 0(s1)               # print to UART
    # right nibble
    and     a0, a1, 0x0000000f
    blt     a0, a2, print_hex_byte_is_digit2
    add     a0, a0, 7+32           
print_hex_byte_is_digit2:
    add     a0, a0, 0x30           
    sb      a0, 0(s1)               # print to UART
    ret


# print char in a0 to terminal
print_ascii:
    mv      t1, a0
    # consider only chars from 0x20-0x7e as printable
    li      t0, 0x20
    blt     t1, t0, print_substitute
    li      t0, 0x7e
    bgt     t1, t0, print_substitute
    j       out_ascii               # char is printable
print_substitute:
    li      t1, '.'                 # print dot if char is not printable
out_ascii:
    sb      t1, 0(s1)               # print to UART
    ret


# print string starting at addr in a0 to terminal
print_string:
    mv      t1, a0  
print_string_next_byte:
    lbu     t0, 0(t1)
    beq     t0, zero, print_string_done
    sb      t0, 0(s1)               # print to UART
    addi    t1, t1, 1
    j       print_string_next_byte
print_string_done:
    ret


# print 32-bit signed decimal in a0 to terminal
# TODO:
print_decimal:
    mv      t1, a0
    bnez    t1, print_decimal_nonzero
    li      t0, '0'
    j       print_decimal_digit
print_decimal_nonzero:
    li      t0, 'n'
print_decimal_digit:
    sb      t0, 0(s1)               # print to UART
print_decimal_done:
    ret


# nice to have for debugging
print_star:
    addi    sp, sp, -(XLEN_BYTES*1)         
    SAVE_X    s0, 0(sp)
    li      s0, '*'
    sb      s0, 0(s1)
    LOAD_X     s0, 0(sp)         
    addi    sp, sp, (XLEN_BYTES*1)
    ret


.data

.align 8

.comm decbuf, 32
