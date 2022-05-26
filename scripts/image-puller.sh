#!/bin/sh

# Assumption is that you have run the "kubectl storageos install" with the "--dry-run" flag
# This should have generated a file called "2-storageos-operator.yaml"
# This is the input file to this script

FILENAME=
LOCALREGISTRYPREFIX=

# specify a space seperated set of files to use as tests. tests are run in paralled across all files

FILENAME="$1"
LOCALREGISTRYPREFIX="$2"

usage ()
{
echo "please run this script as $0 input-filename local-registryname"
exit 1
}


if [ -z "${FILENAME}" ] 
then FILENAME="./2-storageos-operator.yaml"
fi

if [ -f "${FILENAME}" ]
then 
  echo "Found input file"
else
  echo "Please check that the input file ${FILENAME} is correct"
  usage
fi

if [ -z "${LOCALREGISTRYPREFIX}" ] 
then 
  echo "Please make sure you set the local-registryname variable"
  usage
else
  echo "Using ${LOCALREGISTRYPREFIX} as the registry prefix"
fi

# Lets build a list of input images, these we will store as a variable called INPUTS

INPUTS=

INPUTS=$(cat ${FILENAME} |grep RELATED |awk '{ print $2 }')


# Now lets build the pull image block 

echo "Run this block of commands to pull the images"
echo ""

echo "${INPUTS}" | while read SOURCE
do
  echo "docker pull ${SOURCE}"
done

# Now we need to tag the images, lets get the image names only
# You can do this using only shell, no external tool is needed, using Parameter Expansion:
# ${var##* }
# var##* will discard everything from start up to last space from parameter (variable) var

echo ""
echo "Run this block of commands to tag the images"
echo "" 


echo "${INPUTS}" | while read SUFFIX
do
  echo "docker tag ${LOCALREGISTRYPREFIX}/${SUFFIX##*/}"
done

echo ""
echo "Run this block of commands to push the images"
echo "" 


echo "${INPUTS}" | while read SUFFIX
do
  echo "docker push ${LOCALREGISTRYPREFIX}/${SUFFIX##*/}"
done


exit 0
