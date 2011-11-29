
######################
# Clean the existing docs.
rm -rf output/
rm -rf output-docset/
rm -rf ../nimbusdocs/*.*
rm -rf ../nimbusdocs/docsets/
rm -rf ../nimbusdocs/Makefile


######################
# Build the web version of the docs
/Applications/Doxygen.app/Contents/Resources/doxygen Doxyfile > /dev/null

# Move the docs to the nimbus docs folder.
cp -r output/html/* ../nimbusdocs/


######################
# Build the docset version of the docs
/Applications/Doxygen.app/Contents/Resources/doxygen Doxyfile-docset > /dev/null

# Build the docset.
cd output-docset/html
make > /dev/null

# Archive the docset
$(xcode-select -print-path)/usr/bin/docsetutil package com.vaseltior.sgbaseframework.docset > /dev/null

# Move the docs to the nimbus docs folder.
mkdir -p ../../../nimbusdocs/docsets/
mv com.vaseltior.sgbaseframework.xar ../../../nimbusdocs/docsets/com.vaseltior.sgbaseframework.$1.xar

cd ../../
cp nimbusdocset.atom ../../nimbusdocs/
