#!/bin/bash -xe
# This tests the JJB syntax of our job definitions, and generates a
# job-list.txt for use in the check-layout.py test.

temp_dir=$(mktemp -d)
trap 'rm -rf $temp_dir' EXIT

jobs_dir="roles/zuul-launcher/files/jobs/"
jobs_out="$1"
if [ -z "$jobs_out" ]; then
    echo "ERROR: Must specify a file for jobs list output"
    exit 1
fi

jenkins-jobs -l debug test -o "$temp_dir"/jobs "$jobs_dir"

find "$temp_dir"/jobs -printf "%f\n" > "$jobs_out"
