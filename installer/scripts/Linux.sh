#!/bin/bash

if [ "$(id --user)" -eq "0" ]; then
    sudocmd=""
else
    sudocmd="sudo"
fi
$sudocmd apt --quiet update --assume-yes || true
$sudocmd apt --quiet install --assume-yes curl apt-transport-https
$sudocmd apt --quiet purge --assume-yes bomber

curl --silent --show-error https://scribesecuriy.jfrog.io/artifactory/api/security/keypair/scribe-artifactory/public | $sudocmd apt-key add -

if [[ ! -z "${ARTIFACTORY_USERNAME}" ]]  && [ ! -z "${ARTIFACTORY_PASSWORD}" ] ; then
echo "Adding username password"
echo -e "machine https://scribesecuriy.jfrog.io/\nlogin $ARTIFACTORY_USERNAME\npassword $ARTIFACTORY_PASSWORD" | $sudocmd tee /etc/apt/auth.conf.d/scribe > /dev/null
fi 
echo -e "Package: bomber\nPin: release n=stable\nPin-Priority: 900" | $sudocmd tee /etc/apt/preferences.d/scribe_bomber > /dev/null
echo 'deb https://scribesecuriy.jfrog.io/artifactory/scribe-debian-local stable non-free'
echo 'deb https://scribesecuriy.jfrog.io/artifactory/scribe-debian-local stable non-free' | $sudocmd tee /etc/apt/sources.list.d/scribe.list > /dev/null

$sudocmd apt update -o Dir::Etc::sourcelist=/etc/apt/sources.list.d/scribe.list || true
$sudocmd apt --quiet install --assume-yes bomber