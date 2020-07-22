# cpp-project-template
To setup a c++ project in one command.

Integrated development tools
- `git` for version control
- `CMake` for building C++
- `Catch2` for unit test


# Features
The script help to
- check required tools: git, cmake
- setup git repository
- add .gitignore
- add .clang-format
- setup folder structure: app/, build/, cmake/, doc/, extern/, include/, lib/, script/, src/, res/ and test/
- add this repository as a git submodule
- add default CMakeLists.txt
- add useful scripts into script/ folder
- add some code into test/ folder
- build and run project with default empty unit test
- stage new files which are created by above actions

The script can be executed safely in a non-empty project folder without overwriting or modifying any existing file.


## Usage
Simply run  `cpp-project-template [<PROJECT NAME>]` inside a folder.

If ProjectName is not specified, default value is "name of project root directory".


## Installing
### Bash
```
# download repository
git clone https://github.com/daojyun/cpp-project-template.git

# add the executable to PATH
echo "export PATH=\"$(pwd)/cpp-project-template/bin:\$PATH\"" >> ~/.bashrc
```

### Zsh
```
# download repository
git clone https://github.com/daojyun/cpp-project-template.git

# add the executable to PATH
echo "export PATH=\"$(pwd)/cpp-project-template/bin:\$PATH\"" >> ~/.zshrc
```

### by Zinit
```
zinit ice lucid wait depth=1 as'program' pick'bin/*'
zinit light daojyun/cpp-project-template
```
