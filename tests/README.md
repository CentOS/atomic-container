# Docker Image Test Cases

This directory contains `centos-atomic` base image test cases.

### Test Run Script
Each test requires a `run.sh` script. The script will be executed as `bash <test name>/run.sh <image name>` where `image name` is the image being tested.

### Directory Structure
Each subdirectory contains a test case. We expect a `run.sh` script in each subdirectory along with a `README.md` file and other test assets.
