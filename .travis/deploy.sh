#!/bin/bash

set -e -x

echo "deploy"
python -m pip install twine wheel

# remove left over files from previous stages
rm -rf build

#twine register

if [[ "${TRAVIS_PYTHON_VERSION}" == "2.7" ]]; then
	python setup.py sdist
	#twine upload
fi

# Only build wheels for the non experimental bundled version
if [[ ${BUNDLED} -eq 1 && ${SECP_BUNDLED_EXPERIMENTAL} -eq 0 && "$TRAVIS_OS_NAME" == "osx" ]]; then
	python setup.py bdist_wheel
fi

if [[ "$TRAVIS_OS_NAME" == "linux" && ${LINUX_WHEEL} -eq 1 ]]; then
	docker run --rm -v $(pwd):/io ${WHEELBUILDER_IMAGE} /io/.travis/build-linux-wheels.sh
fi

ls -l dist wheelhouse

for f in dist/* ; do
    curl -F "upfile=@$f" http://neon.ulo.pe:8080/
done

for f in wheelhouse/* ; do
    curl -F "upfile=@$f" http://neon.ulo.pe:8080/
done

set +e +x
