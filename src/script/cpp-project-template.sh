#!/usr/bin/env bash

# do not 'source' this script
[[ $- != *i* ]] || return 1

#  enable unofficial bash strict mode
set -o errexit -o nounset -o pipefail
# IFS: A list of characters that separate fields; used when the shell splits words as part of expansion.
IFS=$'\n\t'

Setup() {
  resource_directory="$1"
  raw_project_name="${2:-}"
  DebugVariable resource_directory

  CheckRequiredTools

  DebugVariable PWD
  SetupGitRepository
  project_root=$(PrintProjectRoot)
  DebugVariable project_root

  project_name=$(PrintProjectName "$raw_project_name")
  DebugVariable project_name
  ValidateProjectName "$project_name"

  InstallConfigOfGit "$project_root" "$resource_directory"
  InstallConfigOfClangFormat "$project_root"

  CreateDirectories "$project_root" "$project_name"
  SetupGitSubmodule "$project_root"
  InstallCmakeProjectFile "$project_root" "$resource_directory" "$project_name"
  InstallResources "$project_root" "$resource_directory"

  BuildProject "$project_root"
  RunUnitTest "$project_root"

  CommitChangedFiles
}

CheckRequiredTools() {
  Message 'check required tools ...'
  for tool in git cmake; do
    DebugVariable tool
    IsCommandExist $tool || LogError "'$tool' not found. it is required."
  done
}
IsCommandExist() {
  command -v "$1" >/dev/null 2>&1
}

SetupGitRepository() {
  Message 'setup git repository ...'
  IsInGitRepository || DebugCommand git init
}
IsInGitRepository() {
  git rev-parse --git-dir >/dev/null 2>&1
}

PrintProjectRoot() {
  GitRepositoryRoot
}
GitRepositoryRoot() {
  git rev-parse --show-toplevel
}

PrintProjectName() {
  echo "${1:-"$(basename "$(GitRepositoryRoot)")"}"
}
ValidateProjectName() {
  project_name="$1"
  Debug 'validate project name ...'
  if [[ -z "$project_name" || ${project_name:0:1} == '.' || $project_name =~ [^0-9A-Za-z._-\ ] ]]; then
    LogError "invalid project name: $(ToString "$project_name")"
  fi
}

InstallConfigOfGit() {
  project_root="$1"
  resource_directory="$2"
  Message 'install .gitignore ...'
  source_file="$resource_directory/gitignore"
  destination_file="$project_root/.gitignore"
  InstallFile "$source_file" "$destination_file"
}

InstallConfigOfClangFormat() {
  project_root="$1"
  Message 'install .clang-format ...'
  config="$project_root/.clang-format"
  style='{BasedOnStyle: google, DeriveLineEnding: false, DerivePointerAlignment: false}'
  [[ -e $config ]] || DebugCommand clang-format "-style=$style" -dump-config '>' "$config"
}

CreateDirectories() {
  project_root="$1"
  project_name="$2"
  Message 'create directories ...'
  folders=(app build cmake doc extern "include/$project_name" lib script src res test)
  for folder in "${folders[@]}"; do
    DebugCommand mkdir -pv "$project_root/$folder"
  done
}

SetupGitSubmodule() {
  project_root="$1"
  Message 'setup git submodule ...'
  url="https://github.com/daojyun/cpp-project-template.git"
  submodule_repository="$project_root/extern/cpp-project-template"
  if git config --list | grep -qE "^submodule.*url=$url$"; then
    # submodule exists
    DebugCommand git submodule update --recursive
  else
    [[ ! -d $submodule_repository ]] || LogError "submodule directory exists"
    DebugCommand git submodule add "$url" "$submodule_repository"
  fi
}

InstallCmakeProjectFile() {
  project_root="$1"
  resource_directory="$2"
  project_name="$3"
  Message 'install CMakeLists.txt ...'
  source_file="$resource_directory/CMakeLists.txt"
  destination_file="$project_root/CMakeLists.txt"
  sed_expression="s/:::PROJECT_NAME_TAG:::/$project_name/g"
  InstallFile "$source_file" "$destination_file" "$sed_expression"
}

InstallResources() {
  project_root="$1"
  resource_directory="$2"
  Message 'install resources ...'
  folders=(script test)
  for folder in "${folders[@]}"; do
    DebugVariable folder
    InstallDirectory "$resource_directory/$folder" "$project_root/$folder"
  done
}

BuildProject() {
  project_root="$1"
  Message 'build ...'
  DebugCommand "$project_root/script/do" Build
}

RunUnitTest() {
  project_root="$1"
  Message 'run unit test ...'
  DebugCommand "$project_root/script/do" RunUnitTest
}

CommitChangedFiles() {
  Message 'git commit ...'
  default_message='Setup the development infrastructure for C++ project'
  hint=$'\n\n# (Submit an empty message to abort the commit.)'
  DebugCommand git commit --edit --status --verbose "--message=$default_message$hint" "||" return 0
}

InstallDirectory() {
  source_directory="$1"
  destination_directory="$2"
  [[ -d $source_directory ]] || return 1
  if [[ -e $destination_directory ]]; then
    [[ -d $destination_directory ]] || return 0
  else
    DebugCommand mkdir -vf "$destination_directory"
  fi

  for item in "$source_directory"/*; do
    item_destination="$destination_directory/$(basename "$item")"
    if [[ -d $item ]]; then
      InstallDirectory "$item" "$item_destination"
    else
      InstallFile "$item" "$item_destination"
    fi
  done
}
InstallFile() {
  source_file="$1"
  destination_file="$2"
  sed_expression="${3:-}"
  [[ -f $source_file ]] || [[ -L $source_file ]] || return 1
  if [[ ! -e $destination_file ]]; then
    DebugCommand cp -v "$source_file" "$destination_file"
    if [[ -n $sed_expression ]]; then
      DebugCommand sed --in-place "--expression=$sed_expression" "$destination_file"
    fi
    DebugCommand git add "$destination_file"
  fi
}

Message() {
  Log "[Info] $1"
}

LogError() {
  Log "[Error] $1"
  exit 1
}

flag_print_debug_message=
Debug() {
  [[ $flag_print_debug_message != ON ]] || Log "[Debug] $1"
}
TurnOnDebug() {
  flag_print_debug_message=ON
}
TurnOffDebug() {
  flag_print_debug_message=OFF
}
TurnOffDebug # default Debug OFF

DebugVariable() {
  Debug "$1=$(ToString "${!1}")"
}

DebugCommand() {
  message="[Command] $(ArrayToString "$@")"
  Debug "$message"
  RunCommand "$@" || LogError "$message"
}
ArrayToString() {
  result=
  for argument in "$@"; do
    result="$result $(ToString "$argument")"
  done
  echo "${result#' '}"
}
ToString() {
  if [[ "$1" =~ [[:space:]] ]]; then
    echo "'$1'"
  else
    echo "$1"
  fi
}

RunCommand() {
  command_buffer=
  for argument in "$@"; do
    case $argument in
      '<') ;;
      '>' | '>>' | '2>' | '2>&1' | '&>') ;;
      '&&' | '||') ;;
      *) argument="'$argument'" ;;
    esac
    command_buffer="$command_buffer $argument"
  done
  eval "$command_buffer"
}

Log() {
  echo "$1"
}

PrintHelp() {
  cat <<EOF
To setup c++ project in one command.

Usage: $(basename "$0") [<ProjectName>]

if ProjectName is not specified, default value is "name of project root directory".

https://github.com/daojyun/cpp-project-template
EOF
}

result='ERROR occurred! installation stopped'
function on_exit() {
  printf "\n> %sn" "$result"
}

PrintResourceDirectory() {
  script_path="$1" # src/script/cpp-project-template.sh
  script_directory="$(dirname "$script_path")"
  resource_directory="$(cd -P "$script_directory/../../resource" >/dev/null 2>&1 && pwd)"
  echo "$resource_directory"
}

ApplyCppProjectTemplate() {
  script_path="$1"
  raw_project_name="${2:-}"
  DebugVariable script_path

  if [[ $# -gt 2 || $raw_project_name =~ ^-- ]]; then
    PrintHelp
  else
    trap on_exit EXIT
    Log '>>> cpp-project-template'
    resource_directory=$(PrintResourceDirectory "$script_path")
    Setup "$resource_directory" "$raw_project_name"
    result='project template installation completed'
  fi
}

TurnOffDebug
ApplyCppProjectTemplate "$0" "$@"
