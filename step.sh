#!/bin/bash
set -e

if [[ "${is_debug}" == "true" ]]; then
  set -x
fi

pushd $(mktemp -d)
  # download scanner
  wget https://github.com/SonarSource/sonar-scanner-msbuild/releases/download/${scanner_version}/sonar-scanner-msbuild-${scanner_version}-net46.zip
  unzip sonar-scanner-msbuild-${scanner_version}-net46.zip

  chmod +x sonar-scanner-*/bin/sonar-scanner
  TEMP_DIR=$(pwd)
popd

BEGIN_COMMAND="mono ${TEMP_DIR}/SonarScanner.MSBuild.exe begin /k:${sonarqube_project_key}"

if [[ ! -z ${sonarqube_project_name} ]]; then
  BEGIN_COMMAND="${BEGIN_COMMAND} /n:${sonarqube_project_name}"
fi

if [[ ! -z ${sonarqube_project_version} ]]; then
  BEGIN_COMMAND="${BEGIN_COMMAND} /v:${sonarqube_project_version}"
fi

if [[ ! -z ${scanner_begin_properties} ]]; then
  BEGIN_PROPERTIES=(${scanner_begin_properties})

  for property in "${BEGIN_PROPERTIES[@]}"; do
    BEGIN_COMMAND="${BEGIN_COMMAND} /d:${property}"
  done
fi

eval $BEGIN_COMMAND

if [[ ! -z ${scanner_build_commands} ]]; then
  eval $scanner_build_commands
fi

END_COMMAND="mono ${TEMP_DIR}/SonarScanner.MSBuild.exe end"

if [[ ! -z ${scanner_end_properties} ]]; then
  END_PROPERTIES=(${scanner_end_properties})

  for property in "${END_PROPERTIES[@]}"; do
    END_COMMAND="${END_COMMAND} /d:${property}"
  done
fi

eval $END_COMMAND
