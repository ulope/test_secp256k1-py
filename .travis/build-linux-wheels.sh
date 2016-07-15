#!/bin/bash

set -e -x

# Install a system package required by our library
yum install -y automake pkg-config libffi gmp libtool

# Compile wheels
for PYBIN in /opt/python/*/bin; do
    ${PYBIN}/pip wheel /io/ -w wheelhouse/
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    auditwheel repair $whl -w /io/wheelhouse/
done

# Install packages and test
for PYBIN in /opt/python/*/bin/; do
    ${PYBIN}/pip install secp256k1 --no-index -f /io/wheelhouse
done
