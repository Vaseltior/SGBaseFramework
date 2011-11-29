
######################
# Clean the existing docs.
rm -rf output/
rm -rf output-docset/
rm -rf ../sgbfdocs/*.*
rm -rf ../sgbfdocs/docsets/
rm -rf ../sgbfdocs/Makefile


######################
# Build the web version of the docs
/Applications/Doxygen.app/Contents/Resources/doxygen Doxyfile > /dev/null

# Move the docs to the nimbus docs folder.
cp -r output/html/* ../sgbfdocs/


######################
# Build the docset version of the docs
/Applications/Doxygen.app/Contents/Resources/doxygen Doxyfile-docset > /dev/null

# Build the docset.
cd output-docset/html
make > /dev/null

# Archive the docset
$(xcode-select -print-path)/usr/bin/docsetutil \
package com.vaseltior.sgbaseframework.docset \
-download-url http://vaseltior.github.com/SGBaseFramework/docsets \
-atom ../../sgbaseframeworkdocset.atom > /dev/null

# Move the docs to the nimbus docs folder.
mkdir -p ../sgbfdocs/docsets/
mv com.vaseltior.sgbaseframework.xar ../sgbfdocs/docsets/com.vaseltior.sgbaseframework.$1.xar

cd ../../
cp sgbaseframeworkdocset.atom output-docset/sgbfdocs/
