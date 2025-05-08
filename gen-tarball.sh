#!/bin/bash

# SPDX-FileCopyrightText: Copyright 2025 bitcoin-crazy
# SPDX-License-Identifier: GPL-3.0-or-later

# gen-tarball.sh - generates a tar.xz file for Another.Plasma6.Stock.Market directory

[ -e ChangeLog ] || { echo "Wrong directory. Exiting."; exit 1; }

version=$(cat Another.Plasma6.Stock.Market/metadata.json | grep '"Version": ' | cut -d: -f2 | tr -d '[", ]')

tar -cvJf Another.Plasma6.Stock.Market-$version.tar.xz Another.Plasma6.Stock.Market/

echo " "

ls -lh *.tar.xz
