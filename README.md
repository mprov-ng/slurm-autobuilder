# Slurm Auto Builder
This repository is used as a trigger to fedora copr build service.  On a scheduled basis, it will download the latest slurm, then package it up and send it to copr to build.  If you would like to use the slurm RPMS built with this repo, please see https://copr.fedorainfracloud.org/coprs/mprov/slurm/

This auto builder will build for RHEL 8 and 9 with EPEL repos.  It uses the following flags to the rpmbuild `--with hwloc --with libcurl --with lua --with numa --with ucx --with pmix --with nvml --with freeipmi --without debug`

## Repo config
If you want to use this repo, you can run this command: `dnf copr enable mprov/slurm`

## Special Requests
If you need a specific older version of slurm, a tag can be added to this repo which will trigger a build of that version in copr.  Tags must match the tags from the slurm github repo at https://github.com/SchedMD/slurm/tags If you would like to request this be built, please open an issue with the version requested if it doesn't already exist in the copr repo.
