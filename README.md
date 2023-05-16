# Cookiecutter Ruby

This script generates a basic Ruby project structure based on user input using the Cookie Cutter pattern. It collects various project configuration details from the user and creates the necessary files and directories.

## Prerequisites
Before running this script, ensure that you have Ruby installed on your system.

## Usage
Run the script using the command
```bash
curl -o cookiecutter.rb https://raw.githubusercontent.com/MikaelSantilio/cookiecutter-ruby-datascience/master/cookiecutter.rb; ruby cookiecutter.rb
```


- Follow the prompts and provide the requested information.
- The script will create a new directory with the project slug name (e.g., "my_awesome_project").
- Inside the project directory, you will find the following files and directories:
  - Gemfile: Contains project dependencies specified based on user choices.
  - .env and .env.example: Environment variable configuration files.
  - .ruby-version: Specifies the Ruby version used for the project.
  - .gitignore: Contains a default Git ignore configuration for Ruby projects.
  - LICENSE (if selected): Contains the chosen open-source license text.
  - README.md: Contains information about the project, including the project name, description, author, and license (if selected).
  - config directory: Contains project configuration files.
  - models directory (if selected): Placeholder directory for models.

## Contributing
Bug reports and pull requests are welcome. Please feel free to contribute to this project.

## License
This project is available as open source under the terms of the chosen license. Please refer to the LICENSE file for more details.

