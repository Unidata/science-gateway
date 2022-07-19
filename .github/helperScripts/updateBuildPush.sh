#!/bin/bash

# Check if each branch given in the --branches argument has a rocky Dockerfile
# that is up to date with the version given in the --upstream argument; update,
# build, and push to both github branch and dockerhub if necessary

# Also, seperately check, update, build, and push the most recent Rocky8
# version, as Rocky9 seems to not be fully reliable yet

USAGE='
./updateBuildPush -u|--upstream <upstream-tag> \
	-8|--rocky8 <upstream-rocky8-tag \
	-i|--image <docker-image-name> \
	-t|--token <dockerhub-token> \
	-s|--user <dockerhub-user>
'

while [[ $# > 0 ]]
do
	key=$1
	case $key in
		-u|--upstream)
			UPSTREAM=$2
			shift
			;;
		-8|--rocky8)
			UPSTREAM8=$2
			shift
			;;
		-i|--image)
			IMAGENAME=$2
			shift
			;;
		-t|--token)
			REGISTRYPWD=$2
			shift
			;;
		-s|--user)
			REGISTRYUSER=$2
			shift
			;;
		*)
			echo "Option $1 not recognized"
			echo $USAGE
			exit 1
	esac
	shift
done

if [[ -z "$UPSTREAM" || -z "$UPSTREAM8" || -z "$IMAGENAME" || -z "$REGISTRYPWD" || -z "$REGISTRYUSER" ]]; then
	echo "Invalid number of arguments"
	echo $USAGE
	exit 1
fi

# Operate only on a single branch
# BRANCHES=$(git branch -r --list "origin/*" | grep -v -e "HEAD" | awk -F "/" '{ print $2 }' | xargs)
# BRANCHES=( $BRANCHES )
BRANCHES=("master")

ROCKYPATH="./openstack/rocky"

git config --global user.name 'Github Actions'
git config --global user.email 'respinoza@ucar.edu'	

for BRANCH in "${BRANCHES[@]}"
do
	echo "#######################################"
	echo "Operating on branch: $BRANCH"
	echo "#######################################"
	git checkout $BRANCH || git checkout -b $BRANCH
	CURRENT=$(grep -i "FROM rockylinux" $ROCKYPATH/Dockerfile | awk -F ":" '{ print $2 }')
	CURRENT8=$(grep -i "FROM rockylinux" $ROCKYPATH/Dockerfile.latest-8 | awk -F ":" '{ print $2 }')
	echo "Current version: $CURRENT"
	echo "Current Rocky8 version: $CURRENT8"

	# Most up to date version
	test "$CURRENT" = "$UPSTREAM" &&
	up2date="true" || up2date="false"
	echo "Up to date with latest version ($UPSTREAM)?"; echo $up2date
	if [[ "$up2date" != "true" ]]; then
		# Update Dockerfile
		sed -e "s/FROM rockylinux:.*/FROM rockylinux:$UPSTREAM/g" $ROCKYPATH/Dockerfile -i
		grep -i "FROM" $ROCKYPATH/Dockerfile
		# Build image
		docker build --no-cache -t ${IMAGENAME}:$UPSTREAM $ROCKYPATH
		# Test image
        docker run ${IMAGENAME}:$UPSTREAM | \
        grep "Build successful!" || exit 1
		# Push to git
        git add . && git commit -m "Update to rockylinux:$UPSTREAM" && \
        git push origin $BRANCH
		# Push to dockerhub
        docker logout
        echo $REGISTRYPWD | docker login -u $REGISTRYUSER --password-stdin
        docker push ${IMAGENAME}:$UPSTREAM && \
        { docker logout && echo "Successfully pushed ${IMAGENAME}:$UPSTREAM"; } ||
        { docker logout && echo "Docker push failed" && exit 1; }
	fi

	# Most up to date Rocky8 version
	test "$CURRENT8" = "$UPSTREAM8" &&
	up2date8="true" || up2date8="false"
	echo "Up to date with latest Rocky8 version ($UPSTREAM8)?"; echo $up2date8
	if [[ "$up2date8" != "true" ]]; then
		# Update Dockerfile
		sed -e "s/FROM rockylinux:.*/FROM rockylinux:$UPSTREAM8/g" $ROCKYPATH/Dockerfile.latest-8 -i
		grep -i "FROM" $ROCKYPATH/Dockerfile.latest-8
		# Build image
		docker build --no-cache -f ${ROCKYPATH}/Dockerfile.latest-8 -t ${IMAGENAME}:$UPSTREAM8 $ROCKYPATH
		# Test image
        docker run ${IMAGENAME}:$UPSTREAM8 | \
        grep "Build successful!" || exit 1
		# Push to git
        git add . && git commit -m "Update to rockylinux:$UPSTREAM8" && \
        git push origin $BRANCH
		# Push to dockerhub
        docker logout
        echo $REGISTRYPWD | docker login -u $REGISTRYUSER --password-stdin
        docker push ${IMAGENAME}:$UPSTREAM8 && \
        { docker logout && echo "Successfully pushed ${IMAGENAME}:$UPSTREAM8"; } ||
        { docker logout && echo "Docker push failed" && exit 1; }
	fi
done

if [[ "$up2date" != "true" ]]; then
	docker logout
	echo $REGISTRYPWD | docker login -u $REGISTRYUSER --password-stdin
	docker tag ${IMAGENAME}:$UPSTREAM ${IMAGENAME}:latest && \
	docker push ${IMAGENAME}:latest
fi

if [[ "$up2date8" != "true" ]]; then
	docker logout
	echo $REGISTRYPWD | docker login -u $REGISTRYUSER --password-stdin
	docker tag ${IMAGENAME}:$UPSTREAM8 ${IMAGENAME}:latest-8 && \
	docker push ${IMAGENAME}:latest-8
fi
