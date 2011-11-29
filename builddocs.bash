
######################
# Clean the existing docs.
rm -rf docs/sgbfdocs/

appledoc \
--project-name SGBaseFramework \
--project-version 0.8.0 \
--project-company Vaseltior \
--company-id com.vaseltior \
--docset-feed-name "SGBaseFramework Documentation" \
--docset-feed-url "http://vaseltior.github.com/SGBaseFramework/sgbaseframeworkdocset.atom" \
--docset-package-url  "http://vaseltior.github.com/SGBaseFramework/com.vaseltior.sgbaseframework.xar" \
-h \
-d \
-n \
-u \
--keep-undocumented-objects \
--keep-undocumented-members \
--search-undocumented-doc \
--output docs \
SGBaseFramework

