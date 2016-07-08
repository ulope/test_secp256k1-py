#!/bin/bash

set -e
set -x

# On osx we need to bring our own Python.
# See: https://github.com/travis-ci/travis-ci/issues/2312
if [[ $TRAVIS_OS_NAME == "osx" ]]; then

	# We use the official python.org installers to make sure our wheels are
	# going to be as widely compatible as possible
	PYTHON_PKG_27="https://www.python.org/ftp/python/2.7.12/python-2.7.12-macosx10.6.pkg"
	PYTHON_PKG_33="http://www.python.org/ftp/python/3.3.5/python-3.3.5-macosx10.6.dmg"
	PYTHON_PKG_34="https://www.python.org/ftp/python/3.4.4/python-3.4.4-macosx10.6.pkg"
	PYTHON_PKG_35="https://www.python.org/ftp/python/3.5.2/python-3.5.2-macosx10.6.pkg"
	GET_PIP="https://bootstrap.pypa.io/get-pip.py"

  	# update brew
  	brew update || brew update

  	# Update openssl if necessary
  	brew outdated openssl || brew upgrade openssl

	# Install packages needed to build lib-secp256k1
	for pkg in automake libtool pkg-config libffi gmp; do
		brew list $pkg > /dev/null || brew install $pkg
		brew outdated --quiet $pkg || brew upgrade $pkg
	done

	mkdir -p ~/.cache/python-dl
	# Travis has some funky cd hooks that fuck shit up
	builtin pushd ~/.cache/python-dl

	py_pkg=PYTHON_PKG_${TRAVIS_PYTHON_VERSION//./}
	py_pkg=${!py_pkg}

	# The package might have been cached from a previous run
	if [[ ! -f $(basename ${py_pkg}) ]]; then
		curl -O ${py_pkg}
	fi

	sudo installer -pkg $(basename ${py_pkg}) -target /

	builtin popd

	case "${TRAVIS_PYTHON_VERSION}" in
		2.7)
			python=/Library/Frameworks/Python.framework/Versions/${TRAVIS_PYTHON_VERSION}/bin/python
			virtualenv=virtualenv
			;;
		3.3)
			python=/Library/Frameworks/Python.framework/Versions/${TRAVIS_PYTHON_VERSION}/bin/python3
			virtualenv=virtualenv
			;;
		3.4|3.5)
			python=/Library/Frameworks/Python.framework/Versions/${TRAVIS_PYTHON_VERSION}/bin/python3
			virtualenv=venv
			;;
	esac

	if [[ "${TRAVIS_PYTHON_VERSION}" == "2.7" || "${TRAVIS_PYTHON_VERSION}" == "3.3" ]]; then
		builtin pushd ~
		curl -O ${GET_PIP}
		${python} get-pip.py
		${python} -m pip install --user virtualenv
		builtin popd
	fi

  	mkdir ~/virtualenv
  	${python} -m ${virtualenv} ~/virtualenv/python${TRAVIS_PYTHON_VERSION}
  	source ~/virtualenv/python${TRAVIS_PYTHON_VERSION}/bin/activate
fi

# Build lib-secp256k1 to test non bundled installation
if [[ $BUNDLED -eq 0 ]]; then
	  git clone git://github.com/bitcoin/secp256k1.git libsecp256k1_ext
	  builtin pushd libsecp256k1_ext
	  ./autogen.sh
	  ./configure --enable-module-recovery --enable-experimental --enable-module-ecdh --enable-module-schnorr
	  make
	  builtin popd
fi

set +x
set +e
