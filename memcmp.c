#include <stdio.h>
#include <time.h>
#include <string.h>
#include <stdlib.h>
#define MIN(a, b) a < b ? a : b

extern int memcmp_asm(void *src1, void *src2, int count);
extern int memcmp_orig(void *src1, void *src2, int count);

int main(int argc, char *argv[])
{
	srand(time(NULL));
	int size = atoi(argv[1]);
	int test_count = atoi(argv[2]);
	unsigned char *buffer1 = calloc(size, 1);
	unsigned char *buffer2 = calloc(size, 1);

	clock_t start, end, start2, end2;
	int i, res1, res2;
	double mean_new = 0, mean_old = 0;

	for (i = 0; i < test_count; i++) {
		int num = size - (rand() % (size / 10)) - 1;
		buffer1[num] = rand() % 2;
		buffer2[num] = rand() % 2;
		int st = rand() % (size / 20);
		int st2 = rand() % (size / 20);
		int cnt = MIN(size - st, size - st2);

		start = clock();
		res1 = memcmp_asm(buffer1 + st, buffer2 + st2, cnt);
		end = clock();
		start2 = clock();
		res2 = memcmp_orig(buffer1 + st, buffer2 + st2, cnt);
		end2 = clock();
		mean_new += end - start;
		mean_old += end2 - start2;

		if (res1 * res2 < 0) {
			printf("AHTUNG! %d %d\n", res1, res2);
			return 0;
		}

		if (res1 == 0x1337) {
			printf("Impossible happened... st: %d, num: %d, cnt: %d\n", st, num, cnt);
			return 0;
		}

		buffer1[num] = 0;
		buffer2[num] = 0;

		printf("res: %d %d Old: %ld New: %ld\n", res1, res2, end2 - start2, end - start);
	}

	mean_new /= test_count;
	mean_old /= test_count;

	printf("Mean for new: %lf, for old: %lf. Efficiency coefficient: %lf\n", mean_new, mean_old, mean_old / mean_new);
	free(buffer1);
	free(buffer2);

	return 0;
}
