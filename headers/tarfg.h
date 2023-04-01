/* Credits: https://opensource.apple.com/source/libarchive/libarchive-32/libarchive/contrib/untar.c.auto.html*/

#pragma once

#include <iostream>
#include <string>
#include <vector>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <direct.h>

/* Extracting part */

/* Parse an octal number, ignoring leading and trailing nonsense. */
int parseoct(const char* p, size_t n);

/* Returns true if this is 512 zero bytes */
int is_end_of_archive(const char* p);

/* Create a directory, including parent directories as necessary. */
void create_dir(char* pathname, int mode);

/* Create a file, including parent directory as necessary. */
FILE* create_file(char* pathname, int mode);

/* Verify the tar checksum. */
int verify_checksum(const char* p);

/* Extract a tar archive. */
void untar(FILE* a, const char* path, std::vector<std::string>& FILES);

/* Entry point. */
int untar_file(std::string path);
