#!/bin/bash

echo "count branch commits compared against master or the branch name if provided"
git rev-list --count HEAD ^"${1:-master}"
