#pragma once

#include <algorithm>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <direct.h>

typedef struct
{
	std::string name;
	std::string content;
} VFILE;

typedef struct
{
	std::string name;
	std::vector<VFILE> files;
} VFOLDER;

static std::vector<VFOLDER> DISK_FOLDERS;
static std::vector<VFILE> DISK_FILES;

void init_disk();
void close_disk();

void add_file(std::string name, std::string content);
void add_file_from_disk(std::string path, short save);
void delete_file(std::string name);

void edit_file(std::string name, std::string new_content);
void search_file(std::string name);
