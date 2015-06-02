#!/usr/bin/env bash
set -e
if [ -n "$TRAVIS_PULL_REQUEST" ] && ! [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
    echo "Skipping pull request"
    exit 0
fi
BRANCH=$TRAVIS_TAG
[ -z "$BRANCH" ] && BRANCH=$TRAVIS_BRANCH
if [ -z "$BRANCH" ]; then
    DEFAULT_BRANCH=$( git rev-parse --abbrev-ref HEAD )
    read -p "branch? ($DEFAULT_BRANCH) " BRANCH
    [ -z "$BRANCH" ] && BRANCH=$DEFAULT_BRANCH
fi
FTP_HOST=ftp://ftpcluster.loopia.se
[ -z "$FTP_USER" ] && read -p "ftp user? " FTP_USER
[ -z "$FTP_SECRET" ] && read -s -p "ftp secret? " FTP_SECRET
shopt -s globstar
for file in target/site/**/*; do
    [ -f "$file" ] && curl --ftp-create-dirs -T "$file" "$FTP_HOST/$BRANCH/${file#target/site/}" --user $FTP_USER:$FTP_SECRET
done
