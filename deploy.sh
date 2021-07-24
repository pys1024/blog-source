#!/usr/bin/env bash

hexo g -d
git add .
git commit -m "update"
git push -u origin main
