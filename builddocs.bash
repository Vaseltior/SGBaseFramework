
######################
# Clean the existing docs.
rm -rf docs/sgbfdocs/

appledoc \
--project-name SGBaseFramework \
--project-version 0.8.0 \
--project-company Vaseltior \
--company-id com.vaseltior \
-h \
-d \
-n \
-u \
--output docs/sgbfdocs \
SGBaseFramework

