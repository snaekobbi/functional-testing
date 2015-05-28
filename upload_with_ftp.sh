#!/usr/bin/env bash
set -x
set -e
if [ -n "$TRAVIS_PULL_REQUEST" ] && ! [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
    echo "Skipping pull request"
    exit 0
fi
BRANCH=$TRAVIS_TAG
[ -z "$BRANCH" ] && BRANCH=$TRAVIS_BRANCH
[ -z "$BRANCH" ] && read -p "branch: " BRANCH
FTP_HOST=ftp://ftpcluster.loopia.se
[ -z "$FTP_USER" ] && read -p "ftp user: " FTP_USER
[ -z "$FTP_SECRET" ] && read -s -p "ftp secret: " FTP_SECRET
shopt -s globstar
for file in target/site/**/*; do
    [ -f $file ] && curl --ftp-create-dirs -T $file $FTP_HOST/$BRANCH/${file#target/site/} --user $FTP_USER:$FTP_SECRET
done
( curl $FTP_HOST/branches.json --user $FTP_USER:$FTP_SECRET || echo "[]" ) \
    | jq ". |= .+ [\"${BRANCH}\"] | unique" \
    | curl -T - $FTP_HOST/branches.json --user $FTP_USER:$FTP_SECRET
