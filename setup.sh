#!/bin/bash

###  enable unofficial bash strict mode
set -o errexit -o nounset -o pipefail
# IFS: A list of characters that separate fields; used when the shell splits words as part of expansion.
IFS=$'\n\t'

### start~
echo 'Setup a new project repository'
echo '  use C++, git, cmake and more...'
echo ''

echo 'target directory: ' $1
