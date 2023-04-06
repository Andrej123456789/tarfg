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

	return;
}

void add_file(std::string name, std::string content)
{
	bool make_file_in_existing_folder = false;
	size_t pos_i = 0;

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
	
	if (folder.size() > 0 && file.size() > 0) /* folder and file in name */
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

		if (make_file_in_existing_folder) /* folder exists, but not a file */
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

			DISK_FOLDERS.at(pos_i).files.push_back(new_file);
		}

		else /* neither folder nor file exist */
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

	else if (folder.size() > 0 && file.size() == 0) /* folder in name */
	{
		for (size_t i = 0; i < DISK_FOLDERS.size(); i++)
		{
			if (DISK_FOLDERS.at(i).name == folder)
			{
				std::cout << "Folder " << folder << " already exists!\n";
				return;
			}

			VFOLDER new_folder;

			new_folder.name = folder;
			DISK_FOLDERS.push_back(new_folder);
		}
	}

	else if (folder.size() == 0 && file.size() > 0) /* file in name */
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

	else /* nothing */
	{
		std::cout << "Please enter name of new folder/file!\n";
		return;
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
	
	if (folder.size() > 0 && file.size() > 0) /* folder and file in name */
	{
		for (size_t i = 0; i < DISK_FOLDERS.size(); i++)
		{
			if (DISK_FOLDERS.at(i).name == folder)
			{
				for (size_t j = 0; j < DISK_FOLDERS.at(i).files.size(); j++)
				{
					if (DISK_FOLDERS.at(i).files.at(j).name == file)
					{
						DISK_FOLDERS.at(i).files.erase(DISK_FOLDERS.at(i).files.begin() + j);
						return;
					}
				}
			}
		}

		std::cout << "File " << file << " or folder " << folder << " do not exist and therefore cannot be deleted unless you have PhD in quantum information theory!\n";
		return;
	}

	else if (folder.size() > 0 && file.size() == 0) /* folder in the name */
	{
		for (size_t i = 0; i < DISK_FOLDERS.size(); i++)
		{
			if (DISK_FOLDERS.at(i).name == folder)
			{
				DISK_FOLDERS.erase(DISK_FOLDERS.begin() + i);
				return;
			}
		}

		std::cout << "Folder " << folder << " does not exist and therefore cannot be deleted unless you have PhD in quantum information theory!\n";
		return;
	}

	else if (folder.size() == 0 && file.size() > 0) /* file in the name */
	{
		for (size_t i = 0; i < DISK_FILES.size(); i++)
		{
			if (DISK_FILES.at(i).name == file)
			{
				DISK_FILES.erase(DISK_FILES.begin() + i);
				return;
			}
		}

		std::cout << "File " << file << " does not exist and therefore cannot be deleted unless you have PhD in quantum information theory!\n";
		return;
	}

	else /* nothing */
	{
		std::cout << "Please enter name of new folder/file!\n";
		return;
	}
}

void edit_file(std::string name, std::string new_content)
{
	delete_file(name);
	add_file(name, new_content);
}

void search_file(std::string name)
{
	bool make_file_in_existing_folder = false;
	size_t pos_i = 0;

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
	
	if (folder.size() > 0 && file.size() > 0) /* folder and file in name */
	{
		for (size_t i = 0; i < DISK_FOLDERS.size(); i++)
		{
			if (DISK_FOLDERS.at(i).name == folder)
			{
				for (size_t j = 0; j < DISK_FOLDERS.at(i).files.size(); j++)
				{
					if (DISK_FOLDERS.at(i).files.at(j).name == file)
					{
						std::cout << DISK_FOLDERS.at(i).files.at(j).name << "\n";
						std::cout << '\t' << DISK_FOLDERS.at(i).files.at(j).content << "\n";
						return;
					}

					make_file_in_existing_folder = true;
				}
			}

			pos_i = i;
		}

		if (make_file_in_existing_folder) /* folder exists, but not a file */
		{
			std::cout << DISK_FOLDERS.at(pos_i).name << "\n";

			for (auto &i : DISK_FOLDERS.at(pos_i).files)
			{
				std::cout << '\t' << i.name << "\n";
				std::cout << "\t\t" << i.content << "\n";
			}
		}

		else /* neither folder nor file exist */
		{
			std::cout << "File " << file << " or folder " << folder << " not found!\n";
			return;
		}
	}

	else if (folder.size() > 0 && file.size() == 0) /* folder in name */
	{
		for (size_t i = 0; i < DISK_FOLDERS.size(); i++)
		{
			if (DISK_FOLDERS.at(i).name == folder)
			{
				std::cout << DISK_FOLDERS.at(pos_i).name << "\n";

				for (auto &i : DISK_FOLDERS.at(i).files)
				{
					std::cout << '\t' << i.name << "\n";
					std::cout << "\t\t" << i.content << "\n";
				}
			}
		}
	}

	else if (folder.size() == 0 && file.size() > 0) /* file in name */
	{
		for (size_t i = 0; i < DISK_FILES.size(); i++)
		{
			if (DISK_FILES.at(i).name == file)
			{
				std::cout << file << '\n';
				std::cout << '\t' << DISK_FILES.at(i).content << '\n';
			}
		}
	}

	else /* nothing */
	{
		std::cout << " -------------- FOLDERS -------------- \n";
		for (auto &i : DISK_FOLDERS)
		{
			std::cout << i.name << "\n";

			for (auto &x : i.files)
			{
				std::cout << '\t' << x.name << "\n";
				std::cout << "\t\t" << x.content << "\n";
			}
		}

		std::cout << " -------------- FILES -------------- \n";
		for (auto &j : DISK_FILES)
		{
			std::cout << j.name << '\n';
			std::cout << '\t' << j.content << '\n';
		}
	}
}
