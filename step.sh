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

# echo "This is the value specified for the input 'example_step_input': ${example_step_input}"

#
# --- Export Environment Variables for other Steps:
# You can export Environment Variables for other Steps with
#  envman, which is automatically installed by `bitrise setup`.
# A very simple example:
# envman add --key EXAMPLE_STEP_OUTPUT --value 'the value you want to share'
# Envman can handle piped inputs, which is useful if the text you want to
# share is complex and you don't want to deal with proper bash escaping:
#  cat file_with_complex_input | envman add --KEY EXAMPLE_STEP_OUTPUT
# You can find more usage examples on envman's GitHub page
#  at: https://github.com/bitrise-io/envman

#
# --- Exit codes:
# The exit code of your Step is very important. If you return
#  with a 0 exit code `bitrise` will register your Step as "successful".
# Any non zero exit code will be registered as "failed" by `bitrise`.
