#!/bin/bash
# check for undefined/multiply-defined references

set -x
sed -i.bak 's/cmhlistingsfromfile\*/cmhlistingsfromfile/' s*.tex
sed -i.bak 's/\begin{cmhlistings}\*/\begin{cmhlistings}/' s*.tex
exit
