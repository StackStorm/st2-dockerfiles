#!/usr/bin/env bash

# the first argument must be the name of the container, i.e. st2, st2actionrunner, st2stream
component=$1
# the 2nd argument is the version of the current build and expects at least major.miinor to be provided
# i.e. 3.3.0, 3.3, 2.10.5
build_version=$2

showHelp() {
  echo "Use this script to determine the right tags to be attached to your new image."
  echo
  echo "Syntax: $0 st2component image_version"
  echo "st2component = an valid image of an existing stackstorm component (i.e. st2, st2api, st2stream)"
  echo "image_version = the st2 release used for your current build (i.e. 3.3.0)"
  echo 
  echo "Possible output:"
  echo "0 = no additional tags to be updated"
  echo "1 = update the major.minor tag (i.e. 3.3)"
  echo "2 = update the major and the major.minor tag (i.e. 3 and 3.3)"
  echo
  echo "Run $0 -h|--help to show this usage information."
}

case $1 in
  -h|--help)
    showHelp
    exit
  ;;
esac

if [ "$#" -ne 2 ]; then
  echo "Error: Missing or unexpected number of positional arguments. Expected: 2"
  echo
  showHelp
  exit 1
fi

if [[ ${build_version} =~ ^([0-9]+)\.([0-9]+).?([0-9]*)$ ]]; then
  build_major=${BASH_REMATCH[1]}
  build_minor=${BASH_REMATCH[2]}
  build_patch=${BASH_REMATCH[3]}
else
  echo "The provided version ${build_version} does not have the expected format."
  exit 1
fi

if [ -z ${build_patch} ]; then 
  build_patch=0
fi

# dockerhub lists the tags in ascending order. 1st object = lowest tag; last object = highest tag or latest
docker_tags_json=$(curl -s https://registry.hub.docker.com/v1/repositories/stackstorm/${component}/tags)
readarray -t available_releases < <(echo $docker_tags_json | jq -r '.[] | select(.name | endswith("dev") | not).name' | sort)

# sort returns the list with the highest tag or "latest" as last item
# so change the value below to -2 when introducing the tag latest to get i.e. 3.3.0 instead of latest
latest_release=${available_releases[-1]}
latest_release_array=(${latest_release//\./ })

latest_major=${latest_release_array[0]}
latest_minor=${latest_release_array[1]}

tag_update_flag=0
# possible values of the tag_update flag:
# 0 = no additional tags to be set
# 1 = add the major.minor tag
# 2 = add the tags major and major.minor
# 3 = add the latest tag (for future use)

if [ ${build_version} == ${latest_release} ]; then
  # building a release of the latest st2 version
  tag_update_flag=2
else
  # building a release for a st2 version that does not match the latest version
  if [ ${build_major} -le ${latest_major} ]; then
    # building a release for an older major
    readarray -t build_version_major_minor_matching_releases < <(echo $docker_tags_json | jq -r '.[] | select(.name | endswith("dev") | not) | select(.name | startswith("'"${build_major}.${build_minor}"'")).name')
    if [ ${#build_version_major_minor_matching_releases[@]} -ge 1 ]; then
      # at least one version matching the current builds major and minor version is available
      latest_build_version_major_minor_matching_release=${build_version_major_minor_matching_releases[-1]}
      latest_build_version_major_minor_matching_release_array=(${latest_build_version_major_minor_matching_release//\./ })
      latest_build_version_major_minor_matching_major=${latest_build_version_major_minor_matching_release_array[0]}
      latest_build_version_major_minor_matching_minor=${latest_build_version_major_minor_matching_release_array[1]}
      latest_build_version_major_minor_matching_patch=${latest_build_version_major_minor_matching_release_array[2]}
      if [ ${build_minor} -ge ${latest_build_version_major_minor_matching_patch} ] && [ ${build_patch} -ge ${latest_build_version_major_minor_matching_patch} ]; then
        # building a release for a new or updated patch version of the current or a new minor version
        tag_update_flag=2
    elif [ ${build_minor} -lt ${latest_build_version_major_minor_matching_minor} ] && [ ${build_patch} -ge ${latest_build_version_major_minor_matching_patch} ]; then
        # building a patch release for an older minor version
        tag_update_flag=1
      fi
    else
      # building a release for an old, unreleased major version of st2
      tag_update_flag=2
    fi
  else
    # building a release for a new major version
    tag_update_flag=2
  fi
fi

echo $tag_update_flag