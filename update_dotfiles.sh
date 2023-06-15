#!/bin/bash
# Copy existing spin zshrc
set -e
CONFIG=".install.conf.yaml"
DOTBOT_DIR="dotbot"
#
DOTBOT_BIN="bin/dotbot"
git submodule update --init --recursive "${DOTBOT_DIR}"
"${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${BASEDIR}" -c "${CONFIG}" "${@}"
