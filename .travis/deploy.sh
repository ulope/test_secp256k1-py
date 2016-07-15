#!/bin/bash

set -e -x

echo "deploy"

# remove left over files from previous stages
rm -rf build
mkdir build

python setup.py sdist

# On linux we want to build `manylinux1` wheels. See:
if [[ "$TRAVIS_OS_NAME" == "linux" && ${BUILD_LINUX_WHEELS} -eq 1 ]]; then
	docker run --rm -v $(pwd):/io ${WHEELBUILDER_IMAGE} /io/.travis/build-linux-wheels.sh
else
	# Only build wheels for the non experimental bundled version
	if [[ ${BUNDLED} -eq 1 && ${SECP_BUNDLED_EXPERIMENTAL} -eq 0 && "$TRAVIS_OS_NAME" == "osx" ]]; then
		python -m pip install wheel
		python setup.py bdist_wheel
	fi
fi

ls -l dist

cat <<EOF > ~/.pypirc
[distutils]
index-servers =
	pypitest

[pypitest]
repository = https://testpypi.python.org/pypi
username = ${PYPI_USERNAME}
password = ${PYPI_PASSWORD}
EOF

python -m pip install twine

twine register --repository pypitest dist/secp256k1*.tar.gz
twine upload --repository pypitest --skip-existing dist/secp256k1*.{whl,gz}

set +e +x
