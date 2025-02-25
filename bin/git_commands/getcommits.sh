#!/bin/bash

echo "count branch commits compared against master: "
git rev-list --count HEAD ^"${1:-master}"
