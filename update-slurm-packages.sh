#!/bin/bash

rm -rf slurm* 

# force a checkout of main to make sure we are on main before we do anything
git fetch --all
git checkout main

git clone https://github.com/SchedMD/slurm

cd slurm/
# grab the latest tag or take a tag as an arg.
if [ "$1" == "" ]
then
  TAG=`git tag -l | sort -V | grep -v "start" | egrep -v "rc[0-9]?" | egrep -v "pre[0-9]?" | tail -n1`
  LAST_TAG=`cat ../last_tag`
  if [ "$LAST_TAG" == "$TAG" ]
  then
    # no need to submit a new build, the last tag and current tag are the same.
    echo "No new build required."
    rm -rf slurm/
    exit 0
  fi
  echo -n $TAG > ../last_tag

else
  # a custom tag has been requested.
  TAG=$1
fi

git checkout $TAG

cp slurm.spec ..
cd ..

# patch pmix build req in spec.
cat slurm.spec | sed -e 's/BuildRequires: pmix/BuildRequires: pmix\nBuildRequires: pmix-devel/' > slurm-new.spec
mv slurm-new.spec slurm.spec
VERSION=`cat slurm.spec  | grep ^Version | awk '{print $2}'| head -n1 `
RELEASE=`cat slurm.spec  | egrep "\%def.*rel" | awk '{print $3}'| head -n1`
if [ "$RELEASE" == "1" ]
then
  RELEASE=""
else
  RELEASE="-$RELEASE"
fi

# # patch the source line for build ease.
# cat slurm.spec | sed -e 's/Source:.*\%{slurm_source_dir}\.tar.bz2/Source: slurm.tar.bz2/' > slurm-new.spec
# mv slurm-new.spec slurm.spec

# # patch the setup line for build ease.
# cat slurm.spec | sed -e 's/\%setup -n \%{slurm_source_dir}/%setup -n slurm/' > slurm-new.spec
# mv slurm-new.spec slurm.spec

cp slurm.spec slurm/
# clean up the .git dir in the repo.
rm -rf slurm/.git

# rename the source dir
mv slurm slurm-${VERSION}${RELEASE}

# package it up.
tar -jcf slurm-${VERSION}${RELEASE}.tar.bz2 slurm-${VERSION}${RELEASE}

rm -rf slurm-${VERSION}${RELEASE}

git add .
git config --global user.name "Auto User"
git config --global user.email "mprov@jhu.edu"

git commit -am "Automated build of slurm $TAG"
git push

