#!/bin/bash

# SPDX-FileCopyrightText: Copyright 2025-2026 bitcoin-crazy
# SPDX-License-Identifier: GPL-3.0-or-later

# gen-tarball.sh - generates a tar.xz file for Another.Plasma6.Stock.Market directory

[ -e ChangeLog ] || { echo "Wrong directory. Exiting."; exit 1; }

version=$(grep '"Version": ' Another.Plasma6.Stock.Market/metadata.json | cut -d: -f2 | tr -d '[", ]')
tarball="Another.Plasma6.Stock.Market-$version.tar.xz"

tar -cvJf "$tarball" Another.Plasma6.Stock.Market/

echo " "

ls -lh "$tarball"
