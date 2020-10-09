#!/bin/bash

trap 'echo "# ${BASH_COMMAND}"' DEBUG
read -p Input
