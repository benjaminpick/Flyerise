#!/bin/bash

# Usage: flyerise.sh Input.pdf [Output.pdf] [nb_pages]
# If output not set, it's Input.flyer.pdf

# Dep: sudo apt-get install psutils pdftk 

PDF_INPUT=$1
PDF_OUTPUT=${2:-${1%.pdf}.flyer.pdf}

# Remove all non-digit characters
NB_PAGES=${3//[^[:digit:]]/}
NB_PAGES=${NB_PAGES:-4}

echo "Converting $PDF_INPUT to $PDF_OUTPUT ... (x$NB_PAGES) \n"

TEMP=`tempfile`
rm "$TEMP"

PS_TEMPFILE="$TEMP".ps
PDF_TEMPFILE="$TEMP".pdf
PS_TEMPFILE_2="$TEMP".out.ps

echo -n "Check if Page should be rotated ... "
WIDTH=`pdfinfo "$PDF_INPUT" | grep -e "Page size:" | cut -c 17-19`
HEIGHT=`pdfinfo "$PDF_INPUT" | grep -e "Page size:" | cut -c 26-28`
if [ "$WIDTH" -gt "$HEIGHT" ] ; then
	PAGE_ALIAS="AW "
	echo "Yes" 
else
	PAGE_ALIAS="A  "
	echo "No (width is $WIDTH pt)"
fi

ROTATE=""
for (( c=1; c<=$NB_PAGES; c++)) ; do
 	ROTATE+="$PAGE_ALIAS"
done

echo -n "Check if Page should be multiplied ... "
PAGES=`pdfinfo "$PDF_INPUT" | grep -e "Pages:" | cut -c 17-19`
if [ $PAGES -lt $NB_PAGES ] ; then
	echo "Multiplying page by $NB_PAGES ..."
	pdftk A="$PDF_INPUT" cat $ROTATE output "$PDF_TEMPFILE"
else
	PDF_TEMPFILE=$PDF_INPUT
fi

echo "Converting to ps ..."
pdf2ps -r1200 "$PDF_TEMPFILE" "$PS_TEMPFILE"

echo "Putting $NB_PAGES on 1 page ..."
psnup -$NB_PAGES "$PS_TEMPFILE" "$PS_TEMPFILE_2"

echo "Converting to pdf ..."
ps2pdf -r600 "$PS_TEMPFILE_2" "$PDF_OUTPUT"
