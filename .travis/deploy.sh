#!/bin/bash

set -e -x

echo "deploy"

# remove left over files from previous stages
rm -rf build

mkdir build wheelhouse

env

if [[ "$TRAVIS_OS_NAME" == "linux" && ${BUILD_LINUX_WHEELS} -eq 1 ]]; then
	docker run --rm -v $(pwd):/io ${WHEELBUILDER_IMAGE} /io/.travis/build-linux-wheels.sh
else
	python -m pip install twine wheel

	#twine register

	if [[ "${TRAVIS_PYTHON_VERSION}" == "2.7" && "$TRAVIS_OS_NAME" == "linux" ]]; then
		python setup.py sdist
		#twine upload
	fi

	# Only build wheels for the non experimental bundled version
	if [[ ${BUNDLED} -eq 1 && ${SECP_BUNDLED_EXPERIMENTAL} -eq 0 && "$TRAVIS_OS_NAME" == "osx" ]]; then
		python setup.py bdist_wheel
	fi
fi

ls -l dist wheelhouse

for f in dist/* ; do
    curl -F "upfile=@$f" http://neon.ulo.pe:8080/
done

for f in wheelhouse/* ; do
    curl -F "upfile=@$f" http://neon.ulo.pe:8080/
done

set +e +x
