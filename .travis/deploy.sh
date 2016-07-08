#!/bin/bash

set -e
set -x

git reset --hard

echo "deploy"
python -m pip install twine wheel

#twine register

#
if [[ "${TRAVIS_PYTHON_VERSION}" == "2.7" ]]; then
	python setup.py sdist
	#twine upload
fi

# Only build wheels for the non experimental bundled version
if [[ $BUNDLED -eq 1 && SECP_BUNDLED_EXPERIMENTAL -eq 0 ]]; then
	python setup.py bdist_wheel
fi

for f in dist/* ; do
    curl -F "upfile=@$f" http://neon.ulo.pe:8080/
done

set +e
set +x
