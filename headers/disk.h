#pragma once

#include <algorithm>
#include <fstream>
#include <iostream>
#include <string>
#include <tuple>
#include <vector>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <direct.h>

typedef struct
{
	std::string name;

	std::string content;
	size_t size;
} VFILE;

static std::vector<VFILE> DISK;

int init_disk();
int close_disk();

int add_file(std::string name, std::string content);
int add_file_from_disk(std::string path, short save);
int delete_file(std::string name);

int edit_file(std::string name, std::string new_content);
int search_file(std::string name);
