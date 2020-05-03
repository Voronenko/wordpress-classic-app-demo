#!/bin/bash
if [[ -z "$1" ]]
then
  SUFFIX=""
else
  SUFFIX="-$1"
fi

SELFDIR=$(
  cd $(dirname "$0")
  pwd
)

#source $SELFDIR/deployment/circleci_mapper.sh

PROJECT=wordpress

rm -rf ./build || true
rm ${PROJECT}-*.tgz || true
mkdir -p ./build || true

VERSION=$(git describe --exact-match 2> /dev/null || echo "`git symbolic-ref HEAD 2> /dev/null | cut -b 12-`-`git log --pretty=format:\"%h\" -1`")
GITCOMMIT=`git rev-parse --short HEAD`
GITTAG=`git describe --exact-match --tags $(git log -n1 --pretty='%h') 2>/dev/null`
DATE=`date +%Y-%m-%d:%H:%M:%S`

# do build here, that produces necessary files for artifact under build/ folder
./clean_build.sh

echo "major_version=$VERSION" > build/version.txt
echo "minor_version=$1" >> build/version.txt
echo "git_hash=$GITCOMMIT" >> build/version.txt
echo "git_tag=$GITTAG" >> build/version.txt
echo "built=$DATE" >> build/version.txt

echo PRODUCING ARTIFACT $PROJECT-$VERSION$SUFFIX.tgz  in build/
cd build
tar cfz  ../$PROJECT-$VERSION$SUFFIX.tgz .
