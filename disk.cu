#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include "headers/disk.h"

void init_disk()
{
	return;
}

void close_disk()
{
	DISK_FOLDERS.clear();
	DISK_FILES.clear();
}

void add_file(std::string name, std::string content)
{
	bool make_file_in_existing_folder = false;
	size_t pos_i, pos_j = 0;

	std::string file;
	std::string folder;

	size_t pos = name.find('/');
	if (pos != std::string::npos)
	{
		/* fix a bug (if path contains tow or more slashes)*/
		folder = name.substr(0, pos);
		file = name.substr(pos + 1, name.size() - 1);
	}

	else
	{
		file = name;
	}
	
	if (folder.size() > 0)
	{
		for (size_t i = 0; i < DISK_FOLDERS.size(); i++)
		{
			if (DISK_FOLDERS.at(i).name == folder)
			{
				for (size_t j = 0; j < DISK_FOLDERS.at(i).files.size(); j++)
				{
					if (DISK_FOLDERS.at(i).files.at(j).name == file)
					{
						std::cout << "File " << file << " already exists!\n";
						return;
					}

					make_file_in_existing_folder = true;
				}
			}

			pos_i = i;
		}

		if (make_file_in_existing_folder)
		{
			VFILE new_file;

			new_file.name = file;
			new_file.content = content;

			DISK_FOLDERS.at(pos_i).files.push_back(new_file);
		}

		else
		{
			VFOLDER new_folder;
			VFILE new_file;

			new_file.name = file;
			new_file.content = content;

			new_folder.name = folder;
			new_folder.files.push_back(new_file);

			DISK_FOLDERS.push_back(new_folder);
		}
	}

	else
	{
		for (size_t i = 0; i < DISK_FILES.size(); i++)
		{
			if (DISK_FILES.at(i).name == file)
			{
				std::cout << "File " << file << " already exists!\n";
				return;
			}
		}

		VFILE new_file;

		new_file.name = file;
		new_file.content = content;

		DISK_FILES.push_back(new_file);
	}
}

void add_file_from_disk(std::string path, short save)
{
	std::fstream file;
	file.open(path, std::ios::in);

	if (!file)
	{
		std::cout << "File " << path << " not found!\n";
	}

	else
	{
		std::string name;
		
		size_t pos = path.find('/');
		if (pos != std::string::npos)
		{
			/* fix a bug (if path contains tow or more slashes)*/
			name = path.substr(pos + 1, path.size() - 1);
		}

		else
		{
			name = path;
		}

		std::string str;
		std::string content;
        while (std::getline(file, str))
        {
			content += str;

			if (save == 0) /* do not save few bytes for new line */
			{
				content += "\n";
			}
        }

		add_file(name, content);
    }

    file.close();
}

void delete_file(std::string name)
{
	auto [state, position] = check_existence(name);

	if (state)
	{
		DISK.erase(DISK.begin() + position);
	}

	else
	{
		std::cout << "File " << name << " not found!\n";
	}
}

void edit_file(std::string name, std::string new_content)
{
	auto [state, position] = check_existence(name);

	if (state)
	{
		DISK.at(position).content = new_content;
	}	

	else
	{
		std::cout << "File " << name << " not found!\n";
		std::cout << "Creating new file...\n";

		add_file(name, new_content);
	}

	return 0;
}

int search_file(std::string name)
{
	auto [state, position] = check_existence(name);

	if (state)
	{
		auto file = DISK.at(position);

		std::cout << file.name << '\n';
		std::cout << '\t' << file.content << '\n';
	}

	else
	{
		std::cout << "File " << name << " not found!\n";
	}

	return 0;
}
