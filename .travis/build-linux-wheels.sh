#!/bin/bash

set -e -x

# Install a system package required by our library
yum install -y automake autoconf pkg-config libffi libffi-devel libtool

# Compile wheels
for PYBIN in /opt/python/*/bin; do
	if [[ ${PYBIN} != *"cp26"* ]]; then
    	${PYBIN}/pip wheel /io/ -w wheelhouse/
    	ls -l wheelhouse
    fi
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/secp256k1*.whl; do
    auditwheel repair $whl -w /io/dist/
done

## Install packages and test
#for PYBIN in /opt/python/*/bin/; do
#    ${PYBIN}/pip install secp256k1 --no-index -f /io/wheelhouse
#done
