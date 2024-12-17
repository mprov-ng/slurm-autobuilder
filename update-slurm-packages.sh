#!/bin/bash

git clone https://github.com/SchedMD/slurm

cd slurm/
# grab the latest tag or take a tag as an arg.
if [ "$1" == "" ]
then
  TAG=`git tag -l | sort -V | grep -v "start" | egrep -v "rc[0-9]?" | egrep -v "pre[0-9]?" | tail -n1`
else
  TAG=$1
fi

git checkout $TAG

cp slurm.spec ..
cd ..

# patch pmix build req in spec.
cat slurm.spec | sed -e 's/BuildRequires: pmix/BuildRequires: pmix\nBuildRequires: pmix-devel/' > slurm-new.spec
mv slurm-new.spec slurm.spec

# patch the source line for build ease.
cat slurm.spec | sed -e 's/Source:.*\%{slurm_source_dir}\.tar.bz2/Source: slurm.tar.bz2/' > slurm-new.spec
mv slurm-new.spec slurm.spec

# patch the setup line for build ease.
cat slurm.spec | sed -e 's/\%setup -n \%{slurm_source_dir}/%setup -n slurm/' > slurm-new.spec
mv slurm-new.spec slurm.spec

cp slurm.spec slurm/
# clean up the .git dir in the repo.
rm -rf slurm/.git

# package it up.
tar -jcf slurm.tar.bz2 slurm/

rm -rf slurm/

git add . 
git config --global user.name "Auto User"
git config --global user.email "mprov@jhu.edu"

git commit -am "Automated build of slurm $TAG"
git push 
