all:
	riscv64-unknown-linux-gnu-as -march=rv64img_zbb -o memcmp_asm.o memcmp_asm.S
	riscv64-unknown-linux-gnu-gcc memcmp.c memcmp_asm.o -o memcmp
clean:
	rm -rf *.o
