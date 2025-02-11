#!/bin/bash
# Run this script to update the VICAV instance to the latest versions. 
# It ...
# * pulls the current code of the web application from github.
# * pulls the current content of the web application from github.
# * optionally creates a backup of the dictionary data on vle-curation
# * copies it to this basex setup and restores it there
#
# Note: Assumes deploy-tunocent-content.bxs
# and this file are in the root directory of your basex setup.
# It assumes TUNOCENT content is in the tunocent-content directory
# and that the VICAV webapp is in the webapp/vicav-app directory
# Needs git.

cd $(dirname $0)

if [ ! -f redeploy.settings ]
then echo Missing settings file. Please copy redeploy.settings.dist to redeploy.settings and fill in the credentials.
fi

. redeploy.settings

if [ "$local_username"x = x -o "$local_password"x = x ]; then echo Missing credentials for local BaseX; exit 1; fi
#------ Settings ---------------------
export USERNAME=$local_username
export PASSWORD=$local_password
#-------------------------------------

#------ Update XQuery code -----------
if [ -d ${BUILD_DIR:-webapp/vicav-app} ]
then
  pushd ${BUILD_DIR:-webapp/vicav-app}
  ret=$?
  if [ $ret != "0" ]; then exit $ret; fi
  if [ "$onlytags"x = 'truex' ]
  then
    git reset --hard
    git pull
    uiversion=$(git describe --tags --abbrev=0)
  else
    git pull
    uiversion=$(git describe --tags --always)
  fi
  echo checking out UI ${uiversion}
  git -c advice.detachedHead=false checkout ${uiversion}
  find ./ -type f -and \( -name '*.js' -or -name '*.html' \) -not \( -path './node_modules/*' -or -path './cypress/*' \) -exec sed -i "s~\@version@~$uiversion~g" {} \;
  popd
fi
#-------------------------------------

#------ Update content data from redmine git repository 
echo updating tunocent-content 
if [ ! -d tunocent-content/.git ]; then echo "tunocent-content does not exist or is not a git repository"; fi
pushd tunocent-content
ret=$?
if [ $ret != "0" ]; then exit $ret; fi
if [ "$onlytags"x = 'truex' ]
then
git reset --hard
git pull
dataversion=$(git describe --tags --abbrev=0)
else
git pull
dataversion=$(git describe --tags --always)
fi
echo checking out data ${dataversion}
git -c advice.detachedHead=false checkout ${dataversion}
who=$(git show -s --format='%cN')
when=$(git show -s --format='%as')
message=$(git show -s --format='%B')
sourcebaseuri=$(git remote get-url origin | sed 's/.git$//')/blob/$(git rev-parse HEAD)/
revisionDesc=$(sed ':a;N;$!ba;s/\n/\\n/g' <<EOF
<revisionDesc>
  <change n="$dataversion" who="$who" when="$when">
$message
   </change>
</revisionDesc>
EOF
)
#------- copy all images into the "images" directory in the web application directory
echo "copying image files from tunocent-content to vicav-webapp"
for d in $(ls -d vicav_*)
do echo "Directory $d:"
   cd "$d"
   mkdir -p $(dirname "" $(find . -type f -and \( -name '*.jpg' -or -name '*.JPG' -or -name '*.png' -or -name '*.PNG' -or -name '*.svg' \) -exec echo ${BUILD_DIR:-../../webapp/vicav-app}/images/{} \;))
   find . -type f -and \( -name '*.jpg' -or -name '*.JPG' -or -name '*.png' -or -name '*.PNG' -or -name '*.svg' \) -exec mv -v {} ${BUILD_DIR:-../../webapp/vicav-app}/images/{} \;   
   cd ..
   for filename in $(find "$d" -type f -and -name '*.xml')
   do
      publicationIdno=$(sed ':a;N;$!ba;s/\n/\\n/g' <<EOF
<idno>$sourcebaseuri$filename</idno>
EOF
)
     sed -i "s~\(</publicationStmt>\)~$publicationIdno\\n\1~g" $filename
     sed -i "s~\(</teiHeader>\)~$revisionDesc\\n\1~g" $filename
   done
done
if [ "$CI"x == "truex" ]; then echo "CI: removing .git"; rm -rf .git; fi
versionInfo=$(sed ':a;N;$!ba;s/\n/\\n/g' <<EOF
  <version>
    <backend>$uiversion</backend>
    <data>$dataversion</data>
  </version>
EOF
)
sed -i "s~\(</projectConfig>\)~$versionInfo\\n\1~g" vicav_projects/tunocent.xml
popd

pushd ${BUILD_DIR:-webapp/vicav-app}
find ./ -type f -and \( -name '*.js' -or -name '*.html' \) -not \( -path './node_modules/*' -or -path './cypress/*' \) -exec sed -i "s~\@data-version@~$dataversion~g" {} \;
if [ "$CI"x == "truex" ]; then echo "CI: removing .git"; rm -rf .git; fi 
popd
sed -i "s~webapp/vicav-app/~${BUILD_DIR:-webapp/vicav-app}/~g" deploy-tunocent-content.bxs
./execute-basex-batch.sh deploy-tunocent-content $1
sed -i "s~../webapp/vicav-app/~${BUILD_DIR:-../webapp/vicav-app}/~g" refresh-project-config.xqtl
./execute-basex-batch.sh refresh-project-config.xqtl $1 >/dev/null
pushd tunocent-content
popd
if [ "$CI"x == "truex" ]; then echo "CI: removing content repo"; rm -rf tunocent-content; fi 