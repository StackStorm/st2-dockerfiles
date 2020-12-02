#!/usr/bin/env bash

component=$1
build_version=$2
tmp_release_cache_file=/tmp/dockerhub_st2_releases

if [[ ${build_version} =~ ^([0-9]+)\.([0-9]+).?([0-9]*)$ ]]; then
  build_major=${BASH_REMATCH[1]}
    build_minor=${BASH_REMATCH[2]}
    build_patch=${BASH_REMATCH[3]}
else
  echo "The provided version ${build_version} does not have the expected format."
  exit 1
fi

# dockerhub lists the tags in ascending order. 1st object = lowest tag; last object = highest tag
curl -s https://registry.hub.docker.com/v1/repositories/stackstorm/${component}/tags | jq -r '.[] | select(.name | endswith("dev") | not).name' > ${tmp_release_cache_file}

if [ -z ${build_patch} ]; then 
  build_patch=0
fi

readarray -t available_releases < $tmp_release_cache_file
latest_release=${available_releases[-1]}
latest_release_array=(${latest_release//\./ })

latest_major=${latest_release_array[0]}
latest_minor=${latest_release_array[1]}
latest_patch=${latest_release_array[2]}

tag_update_flag=0
# possible values of the tag_update flag:
# 0 = no additional tags to be set
# 1 = add the major.minor tag
# 2 = add the tags major and major.minor
# 3 = add the latest tag (for future use)

if [ ${build_version} == ${latest_release} ]; then
  tag_update_flag=2
else
  if [ ${build_major} -lt ${latest_major} ]; then
    readarray -t build_version_major_matching_releases < <(grep ${build_major} $tmp_release_cache_file)
    latest_build_version_major_matching_release=${build_version_major_matching_releases[-1]}
    latest_build_version_major_matching_release_array=(${latest_build_version_major_matching_release//\./ })
    latest_build_version_major_matching_minor=${latest_build_version_major_matching_release_array[1]}
    latest_build_version_major_matching_patch=${latest_build_version_major_matching_release_array[2]}
    if [ ${build_minor} -gt ${latest_build_version_major_matching_minor} ]; then
      tag_update_flag=2
    elif [ ${build_minor} -eq ${latest_build_version_major_matching_minor} ] && [ ${build_patch} -ge ${latest_build_version_major_matching_patch} ]; then
      tag_update_flag=2
    else
      # building a release for a major version that is *not* the latest of the given major
      readarray -t build_version_major_minor_matching_releases < <(grep ${build_major}.${build_minor} $tmp_release_cache_file)
      latest_build_version_major_minor_matching_release=${build_version_major_matching_releases[-1]}
      latest_build_version_major_minor_matching_release_array=(${latest_build_version_major_minor_matching_release//\./ })
      latest_build_version_major_minor_matching_patch=${latest_build_version_major_minor_matching_release_array[2]}
      if [ ${build_patch} -ge ${latest_build_version_major_minor_matching_patch}]; then
        tag_update_flag=1
      fi
    fi
  else
    # building a release for a new major version
    tag_update_flag=2
  fi
fi

echo $tag_update_flag
