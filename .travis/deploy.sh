#!/bin/bash

set -e
set -x

env
python --version

exit 0

#twine register

#
if [[ "${TRAVIS_PYTHON_VERSION}" == "2.7" ]]; then
	python setup.py sdist
	twine upload
fi

# Only build wheels for the non experimental bundled version
if [[ $BUNDLED -eq 1 && SECP_BUNDLED_EXPERIMENTAL -eq 0 ]]; then
	python -m pip install twine
fi
