#!/bin/bash

set -e
set -x

# On osx we need to bring our own Python.
# See: https://github.com/travis-ci/travis-ci/issues/2312
if [[ $TRAVIS_OS_NAME == "osx" ]]; then
  	# update brew
  	brew update || brew update

  	# Update openssl if necessary
  	brew outdated openssl || brew upgrade openssl

	# Install packages needed to build lib-secp256k1
	brew install automake libtool pkg-config libffi gmp

  	# install pyenv
  	git clone https://github.com/yyuu/pyenv.git ~/.pyenv
  	PYENV_ROOT="$HOME/.pyenv"
  	PATH="$PYENV_ROOT/bin:$PATH"
  	PYTHON_CONFIGURE_OPTS="--enable-framework"
  	eval "$(pyenv init -)"

  	case "${TRAVIS_PYTHON_VERSION}" in
  		2.7)
  			curl -O https://bootstrap.pypa.io/get-pip.py
  			python get-pip.py --user
  			;;
  		3.3)
  			pyenv install 3.3.6
  			pyenv global 3.3.6
  			;;
  		3.4)
  			pyenv install 3.4.4
  			pyenv global 3.4.4
  			;;
  		3.5)
  			pyenv install 3.5.2
  			pyenv global 3.5.2
  			;;
  	esac
  	pyenv rehash
  	python -m pip install --user virtualenv
fi


python -m virtualenv ~/.venv
source ~/.venv/bin/activate
pip install tox codecov


# Build lib-secp256k1 to test non bundled installation
if [[ $BUNDLED -eq 0 ]]; then
	  git clone git://github.com/bitcoin/secp256k1.git libsecp256k1_ext
	  pushd libsecp256k1_ext
	  ./autogen.sh
	  ./configure --enable-module-recovery --enable-experimental --enable-module-ecdh --enable-module-schnorr
	  make
	  popd
fi
