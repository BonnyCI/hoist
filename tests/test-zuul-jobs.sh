#!/bin/bash -xe
# This tests the JJB syntax of our job definitions, and generates a
# job-list.txt for use in the layout-checks.py test.

jobs_dir="roles/zuul/files/jobs/"
jobs_out=$1
if [ -z "$jobs_out" ]; then
    echo "ERROR: Must specify a file for jobs list output"
    exit 1
fi

temp_dir=$(mktemp -d)
trap 'rm -rf $temp_dir' EXIT

virtualenv "$temp_dir"
source "$temp_dir"/bin/activate
pip install jenkins-job-builder
jenkins-jobs -l debug test -o "$temp_dir"/jobs "$jobs_dir"

find "$temp_dir"/jobs -printf "%f\n" > "$jobs_out"
