#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include "headers/disk.h"

std::tuple<bool, size_t> check_existence(std::string name)
{
	bool state = false;
	size_t position = 0;
	for (size_t i = 0; i < DISK.size(); i++)
	{
		if (DISK.at(i).name == name)
		{
			state = true;
			position = i;

			break;
		}
	}

	return {state, position};
}

int init_disk()
{
	return 0;
}

int close_disk()
{
	DISK.clear();
	return 0;
}

int add_file(std::string name, std::string content)
{
	auto [state, position] = check_existence(name);

	if (state)
	{
		std::cout << "File " << name << " already exists!\n";
		return 0;
	}

	VFILE file;

	file.name = name;
	file.content = content;

	file.size = file.content.size();
	
	DISK.push_back(file);
	return 0;
}

int add_file_from_disk(std::string path, short save)
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
	return 0;
}

int delete_file(std::string name)
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

	return 0;
}

int edit_file(std::string name, std::string new_content)
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
