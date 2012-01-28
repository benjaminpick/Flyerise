#!/bin/bash

PDF_INPUT=$1
PDF_OUTPUT=${2:-${1%.pdf}.flyer_a5.pdf}

flyerise.sh "$PDF_INPUT" "$PDF_OUTPUT" 2
