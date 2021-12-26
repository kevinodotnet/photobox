#!/bin/bash

echo ~/src/photobox/injest.rb \
  --dst /mnt/disk3/photobox \
  --no_md5 \
  --no_date_prefix \
  --src . \
  --prefix helen \
  --no_changes
