#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
make setup -C $DIR
sudo make k8s -C $DIR
make install-aws -C $DIR
exec bash -l
