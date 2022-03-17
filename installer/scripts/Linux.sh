#!/bin/bash
set -x

if [ "$(id --user)" -eq "0" ]; then
    sudocmd=""
else
    sudocmd="sudo"
fi
echo "aaaaaaaaaaaaaaa 1"
# $sudocmd apt --quiet update --assume-yes || true
# $sudocmd apt --quiet install --assume-yes curl
$sudocmd apt --quiet purge --assume-yes bomber
echo "aaaaaaaaaaaaaaa 2"
curl --silent --show-error https://scribesecuriy.jfrog.io/artifactory/api/security/keypair/scribe-artifactory/public | $sudocmd apt-key add -
echo "aaaaaaaaaaaaaaa 3"
if [[ ! -z "${ARTIFACTORY_USERNAME}" ]]  && [ ! -z "${ARTIFACTORY_PASSWORD}" ] ; then
echo "Adding username password"
echo -e "machine https://scribesecuriy.jfrog.io/\nlogin $ARTIFACTORY_USERNAME\npassword $ARTIFACTORY_PASSWORD" | $sudocmd tee /etc/apt/auth.conf.d/scribe > /dev/null
fi 
echo "aaaaaaaaaaaaaaa 4"
echo -e "Package: bomber\nPin: release n=stable\nPin-Priority: 900" | $sudocmd tee /etc/apt/preferences.d/scribe_bomber > /dev/null
echo "aaaaaaaaaaaaaaa 5"
echo 'deb https://scribesecuriy.jfrog.io/artifactory/scribe-debian-local stable non-free'
echo "aaaaaaaaaaaaaaa 6"
echo 'deb https://scribesecuriy.jfrog.io/artifactory/scribe-debian-local stable non-free' | $sudocmd tee /etc/apt/sources.list.d/scribe.list > /dev/null
echo "aaaaaaaaaaaaaaa 8"

$sudocmd apt update -o Dir::Etc::sourcelist=/etc/apt/sources.list.d/scribe.list || true
$sudocmd apt --quiet install --assume-yes bomber