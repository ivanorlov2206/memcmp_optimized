.text
.global memcmp_asm
.equ mask, 0xFF

memcmp_asm:
# a0 - data1
# a1 - data2
# a2 - count of bytes

# jump to byte iteration for small count
sltiu t0, a2, 256
bnez t0, byte_iter

# if addresses are unaligned and have different remainder of division by 8,
# jump to the byte iteration, as we can't compare data by words in this case
andi t0, a1, 0x07
andi t1, a0, 0x07
bne t0, t1, byte_iter

# get 8 - (count % 8)
xori t0, t0, 0x07
addi t0, t0, 1

# iterate over bytes until the both addresses are aligned
align_cycle:
beqz t0, continue
lb t1, 0(a0)
lb t2, 0(a1)
addi a0, a0, 1
addi a1, a1, 1
addi t0, t0, -1
beq t1, t2, align_cycle

# we have found the unequal bytes, so return
blt t1, t2, retn
bgt t1, t2, retp

continue:
# get the count remainder of division by 8. We will iterate over it at the end
srli t0, a2, 3
andi a2, a2, 0x07

iter_words:
beqz t0, byte_iter
ld t1, 0(a0)
ld t2, 0(a1)
addi t0, t0, -1
addi a0, a0, 8
addi a1, a1, 8
beq t1, t2, iter_words

# we have found the unequal words, iterate over them byte by byte
addi a0, a0, -8
addi a1, a1, -8
li a2, 8
j byte_iter

li a0, 0x1337
ret

ret0:
li a0, 0
ret

retn:
li a0, -1
ret

retp:
li a0, 1
ret

byte_iter:
beqz a2, ret0
lbu t1, 0(a0)
lbu t2, 0(a1)
addi a2, a2, -1
addi a0, a0, 1
addi a1, a1, 1
beq t1, t2, byte_iter

blt t1, t2, retn
bgt t1, t2, retp

li a0, 0x1337
ret


.global memcmp_orig
memcmp_orig:
addi	sp,sp,-16
sd	s0,8(sp)
addi	s0,sp,16
beqz	a2, m2
mv	a5,a0
add	a2,a2,a0
j	m2
m4:
beq	a5,a2, m3
m2:
lbu	a0,0(a5)
lbu	a4,0(a1)
addi	a5,a5,1
addi	a1,a1,1
subw	a0,a0,a4
beqz	a0, m4
m3:
ld	s0,8(sp)
addi	sp,sp,16
ret

m1:
li	a0,0
j	m3

