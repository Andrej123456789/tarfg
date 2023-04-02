﻿#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <iostream>
#include <sstream>
#include <string>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "headers/disk.h"
#include "microtar/microtar.h"

void error(int errorc)
{
    switch (errorc)
    {
        case 0:
            fprintf(stderr, "usage : tarfg <command> <value>\n");
            exit(0);
            break;
    }
}

void split_str(std::string const& str, const char delim, std::vector<std::string>& out)
{
    /* create a stream from the string */
    std::stringstream s(str);

    std::string s2;
    while (getline(s, s2, delim))
    {
        out.push_back(s2); /* store the string in s2 */
    }
}

void tar(const char* name, short save, std::vector<std::string>& FILES)
{
    mtar_t tar;

    /* Open archive for writing */
    mtar_open(&tar, name, "w");

    for (auto &i : FILES)
    {
        std::fstream file;
	    file.open(i, std::ios::in);

        std::string str;
		std::string content;
        while (std::getline(file, str))
        {
			/* ingore this - 5350 - U */
			content += str;

			if (save == 0) /* do not save few bytes for new line */
			{
				content += "\n";
			}
        }

        mtar_write_file_header(&tar, i.c_str(), content.size());
        mtar_write_data(&tar, content.c_str(), content.size());
    }

    /* Finalize -- this needs to be the last thing done before closing */
    mtar_finalize(&tar);

    /* Close archive */
    mtar_close(&tar);
}

void untar(const char* path)
{
    mtar_t tar;
    mtar_header_t h;
    char *p;

    std::vector<std::string> FILES;

    /* Open archive for reading */
    mtar_open(&tar, path, "r");

    /* Print a string */
    printf("Extracting from %s\n", path);

    /* Print all file names and sizes */
    while ((mtar_read_header(&tar, &h)) != MTAR_ENULLRECORD)
    {
        printf("\t %s (%d bytes)\n", h.name, h.size);
        FILES.push_back(std::string(h.name));

        mtar_next(&tar);
    }

    for (auto &i : FILES)
    {
        /* Load and save content of found files */
        mtar_find(&tar, i.c_str(), &h);
        p = (char*)calloc(1, h.size + 1);
        mtar_read_data(&tar, p, h.size);
        
        add_file(i, std::string(p));
    }

    /* Free the string */
    free(p);

    /* Close archive */
    mtar_close(&tar);
}

void shell()
{
    while (true)
    {
        std::string command = "";
        std::string input = "";

again:
        std::cout << ">> ";
        getline(std::cin, input);

        std::vector<std::string> arguments = {};
        const char delim = ' ';
        split_str(input, delim, arguments);
        command = const_cast<char*>(strtok(const_cast<char*>(input.c_str()), " "));

        if (strcmp(command.c_str(), "help") == 0)
        {

        }

        else if (strcmp(command.c_str(), "exit") == 0)
        {
            exit(0);
        }

        else if (command == "tar")
        {
            if (arguments.size() < 3)
            {
                std::cout << "Not enough arguments!\n";
                goto again;
            }

            std::vector<std::string> FILES;
            for (size_t i = 0; i < arguments.size(); i++)
            {
                if (i < 3)
                {
                    continue;
                }

                else
                {
                    FILES.push_back(arguments[i]);
                }
            }

            tar(arguments[1].c_str(), std::stoi(arguments[2]), FILES);
        }

        else if (command == "untar")
        {
            if (arguments.size() < 2)
            {
                std::cout << "Not enough arguments!\n";
                goto again;
            }

            untar(arguments[1].c_str());
        }

        else if (command == "add")
        {
            if (arguments.size() < 3)
            {
                std::cout << "Not enough arguments!\n";
                goto again;
            }

            std::string argument;
            for (size_t i = 0; i < arguments.size(); i++)
            {
                if (i < 2)
                {
                    continue;
                }

                else
                {
                    argument += arguments[i];
                    argument += " ";
                }
            }

            add_file(arguments[1], argument);
        }

        else if (command == "add_disk")
        {
            if (arguments.size() < 3)
            {
                std::cout << "not enough arguments!\n";
                goto again;
            }

            add_file_from_disk(arguments[1], std::stoi(arguments[2]));
        }

        else if (command == "delete")
        {
            if (arguments.size() < 3)
            {
                std::cout << "Not enough arguments!\n";
                goto again;
            }

            delete_file(arguments[1]);
        }

        else if (command == "edit")
        {
            if (arguments.size() < 3)
            {
                std::cout << "Not enough arguments!\n";
                goto again;
            }

            std::string argument;
            for (size_t i = 0; i < arguments.size(); i++)
            {
                if (i < 2)
                {
                    continue;
                }

                else
                {
                    argument += arguments[i];
                    argument += " ";
                }
            }

            edit_file(arguments[1], argument);
        }

        else if (command == "search")
        {
            if (arguments.size() < 2)
            {
                std::cout << "Not enough arguments!\n";
                goto again;
            }

            search_file(arguments[1]);
        }

        else
        {
            std::cout << "Invalid command! See help for avabible commands!\n";
        }

        input = "";
    }
}

int main()
{
    char cwd[256];
    getcwd(cwd, sizeof(cwd));

    std::cout << cwd << std::endl;

    init_disk();
    shell();

    close_disk();
	return 0;
}
