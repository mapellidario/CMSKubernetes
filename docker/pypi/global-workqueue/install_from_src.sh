#!/bin/bash

### This script is used to deploy central services pypi package inside a Docker image
### based on the WMAgent version/tag provided at build time.

set -e
set -u
set -o pipefail
set -x

pythonLib=$(python -c "import site; site.getsitepackages()")

help(){
    echo -e $1
    cat <<EOF

The basic WMAgent deployment script for Docker image creation:
Usage: install_from_src.sh -t <wmagent_tag> -p <package> -r <repository>

    -t <wmagent_tag>    The WMAgent version/tag to be used for the Docker image creation

Example: ./install_from_src.sh -t 2.2.0.2 -p global-workqueue -r mapellidario

EOF
}

usage(){
    help $1
    exit 1
}

WMA_TAG=None

### Argument parsing:
while getopts ":t:r:p:h" opt; do
    case ${opt} in
        t) WMA_TAG=$OPTARG ;;
        r) REPO=$OPTARG ;;
        p) PKG=$OPTARG ;;
        h) help; exit $? ;;
        \? )
            msg="Invalid Option: -$OPTARG"
            usage "$msg" ;;
        : )
            msg="Invalid Option: -$OPTARG requires an argument"
            usage "$msg" ;;
    esac
done

# First upgrade pip to the latest version:
pip install wheel
pip install --upgrade pip

# Second deploy the package. Interrupt on error:
# old: do it from pip
##pip install wmagent==$WMA_TAG || { err=$?; echo "Failed to install wmagent:$WMA_TAG at $WMA_DEPLOY_DIR" ; exit $err ; }
# install from source
git clone https://github.com/${REPO}/WMCore.git
pushd WMCore || exit
export WMA_SRC_DIR=$PWD
git checkout tags/${WMA_TAG} -b ${REPO}_${WMA_TAG}
#bash bin/test_local_build_and_install.sh
## install wmagent only
python3 -m pip install --upgrade pip setuptools wheel
cp setup.py setup.py.orig
cp requirements.txt requirements.txt.orig
cat requirements.txt | grep -v gfal > requirements.${PKG}.txt
awk "/(${PKG}$)|(${PKG},)/ {print \$1}" requirements.${PKG}.txt > requirements.txt
sed "s/PACKAGE_TO_BUILD/${PKG}/" setup_template.py > setup.py
python3 setup.py sdist bdist_wheel
python3 -m pip install -r requirements.txt
python3 -m pip install --no-index --find-links=dist/ ${PKG}
popd || exit
echo "Done $stepMsg!" && echo

