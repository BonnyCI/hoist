#!/bin/bash -xe
# jobs-checks.sh checks job definitions and generates a job-list.txt
# layout-checks.py consumes that lists as part of its layout validation
"$(dirname "$0")"/check-jobs.sh job-list.txt
"$(dirname "$0")"/check-unused-jobs.sh job-list.txt
"$(dirname "$0")"/check-layout.py job-list.txt
