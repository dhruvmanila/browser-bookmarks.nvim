/*
 * Dump mozilla style lz4json files.
 *
 * Copyright (c) 2014 Intel Corporation
 * Author: Andi Kleen
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that: (1) source code distributions
 * retain the above copyright notice and this paragraph in its entirety, (2)
 * distributions including binary code include the above copyright notice and
 * this paragraph in its entirety in the documentation or other materials
 * provided with the distribution
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */

/* File format reference:
   https://dxr.mozilla.org/mozilla-central/source/toolkit/components/lz4/lz4.js
 */
#include <errno.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#ifndef __APPLE__
#include <endian.h>
#else
#define htole32(x) x /* assume apple targets are little endian */
#endif

#include "lz4.h"

int main(int ac, char **av)
{
	while (*++av) {
		int fd = open(*av, O_RDONLY);
		if (fd < 0) {
			perror(*av);
			continue;
		}
		struct stat st;
		if (fstat(fd, &st) < 0) {
			perror(*av);
			exit(1);
		}
		if (st.st_size < 12) {
			fprintf(stderr, "%s: file too short\n", *av);
			exit(1);
		}

		char *map = mmap(NULL, st.st_size, PROT_READ, MAP_SHARED, fd, 0);
		if (map == (char *)-1) {
			perror(*av);
			exit(1);
		}
		if (memcmp(map, "mozLz40", 8)) {
			fprintf(stderr, "%s: not a mozLZ4a file\n", *av);
			exit(1);
		}
		size_t outsz = htole32(*(uint32_t *) (map + 8));
		char *out = malloc(outsz);
		if (!out) {
			fprintf(stderr, "Cannot allocate memory\n");
			exit(1);
		}
		if (LZ4_decompress_safe_partial(map + 12, out, st.st_size - 12, outsz, outsz) < 0) {
			fprintf(stderr, "%s: decompression error\n", *av);
			exit(1);
		}
		ssize_t decsz = write(1, out, outsz);
		if (decsz < 0 || decsz != outsz) {
			if (decsz >= 0)
				errno = EIO;
			perror("write");
			exit(1);
		}
		free(out);
		munmap(map, st.st_size);
		close(fd);

	}
	return 0;
}
