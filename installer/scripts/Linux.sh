#!/bin/bash
set -x

tools=$1


if [ "$(id --user)" -eq "0" ]; then
    sudocmd=""
else
    sudocmd="sudo"
fi
$sudocmd apt --quiet update --assume-yes || true
$sudocmd apt --quiet install --assume-yes curl
curl --silent --show-error https://scribesecuriy.jfrog.io/artifactory/api/security/keypair/scribe-artifactory/public | $sudocmd apt-key add -
if [[ ! -z "${ARTIFACTORY_USERNAME}" ]]  && [ ! -z "${ARTIFACTORY_PASSWORD}" ] ; then
echo "Adding username password"
echo -e "machine https://scribesecuriy.jfrog.io/\nlogin $ARTIFACTORY_USERNAME\npassword $ARTIFACTORY_PASSWORD" | $sudocmd tee /etc/apt/auth.conf.d/scribe > /dev/null
fi 

echo 'deb https://scribesecuriy.jfrog.io/artifactory/scribe-debian-local stable non-free'
echo 'deb  https://scribesecuriy.jfrog.io/artifactory/scribe-debian-local stable non-free' | $sudocmd tee /etc/apt/sources.list.d/scribe.list > /dev/null

# 2DO - remove arch after porting to amd64 distribution complete
echo 'deb  [arch=x86_64] https://scribesecuriy.jfrog.io/artifactory/scribe-debian-local stable non-free'
echo 'deb  [arch=x86_64]  https://scribesecuriy.jfrog.io/artifactory/scribe-debian-local stable non-free' | $sudocmd tee /etc/apt/sources.list.d/scribe.list > /dev/null


$sudocmd apt update -o Dir::Etc::sourcelist=/etc/apt/sources.list.d/scribe.list || true


for tool in ${tools}; do
    tool=$(echo "${tool}" | awk -F: '{print $1}')
    version=$(echo "${tool}" | awk -F: '{print $2}')
    $sudocmd apt --quiet purge --assume-yes $tool || true
    apt show $tool || true | grep -q scribe 
    if [ $? -eq 0 ] ; then
        if [[ ! -z "${version}" ]] ; then
        $sudocmd apt --quiet install --assume-yes $tool=$version
        else
        $sudocmd apt --quiet install --assume-yes $tool
        fi
    else
        echo "Scribe $tool could not be found"
        exit 1
    fi

done


