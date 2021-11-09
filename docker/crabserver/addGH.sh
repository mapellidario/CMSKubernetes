#!/bin/bash
# add GitHub repositories for CRABServer and WMCore

# 0. find the crabserver directory
# beware that according to whom makes the build the top dir could be called
# sw, sw.belforte, sw.crab_master etc. etc.
# But in our images there is a single /sw*, a single scramarch in ../sw*/
# and a single release name in /data/srv/current/sw*/*/cms/crabserver/*
# whih usually is the GH tag plus possible a suffix like -compN
CRABServerDir=`realpath /data/srv/current/sw*/*/cms/crabserver/*`


# 1. find which GitHub tags were installed
# beware that directory name in $CRABServerDir may not be the GH tag but rather
# name assigned at build time like v3.230303-comp4
export PYTHONPATH=${CRABServerDir}/lib/python2.7/site-packages
CRABServerGHTag=`python -c "from CRABInterface import __version__; print __version__"`
WMCoreGHTag=`python -c "from WMCore import __version__; print __version__"`

# 2. create directories for repositories and clone
mkdir /data/repos
pushd /data/repos
git clone https://github.com/dmwm/CRABServer.git
git clone https://github.com/dmwm/WMCore.git

# 3. checkout the installed tags and add ptrs to developers repos
cd CRABServer
git checkout $CRABServerGHTag
git remote add stefano https://github.com/belforte/CRABServer.git
git remote add daina https://github.com/ddaina/CRABServer.git
git remote add mapellidario https://github.com/mapellidario/CRABServer.git
git remote add diego https://github.com/dciangot/CRABServer.git
cd ..
cd WMCore
git checkout $WMCoreGHTag
git remote add stefano https://github.com/belforte/WMCore.git
git remote add daina https://github.com/ddaina/WMCore.git
git remote add mapellidario https://github.com/mapellidario/WMCore.git
git remote add diego https://github.com/dciangot/WMCore.git

# add dummy global names to git for git stash to work
git config --global user.email dummy@nowhere
git config --global user.name dummy

# 4. hack init.sh to point PYTHONPATH to the GH repos when $RUN_FROM_GH is True
CRABServerInitDir=${CRABServerDir}/etc/profile.d/
cd ${CRABServerInitDir}
cat init.sh | grep -v PYTHONPATH > new-init.sh
cat << EOF >> new-init.sh
if [ "\$RUN_FROM_GH" = "True" ]; then
  export PYTHONPATH=/data/repos/CRABServer/src/python:/data/repos/WMCore/src/python/:\$PYTHONPATH
else
EOF
cat init.sh | grep PYTHONPATH | sed "s/\[/  \[/" >> new-init.sh
echo "fi" >> new-init.sh
mv new-init.sh init.sh

# 5. all done, reset cwd and exit
popd
