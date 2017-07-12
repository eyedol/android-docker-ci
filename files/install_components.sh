#!/bin/bash
# Source the android components that needs to be installed
COMPONENTS_FILE=./files/android-components-versions.sh
source "${COMPONENTS_FILE}"
# Install android components
sdkmanager  "\"$platforms"\" "\"$build_tools"\" "\"$extras"\" "\"$platform_tools"\" "\"$tools"\" "\"$system_images"\"
# Install android emulator called test without a UI
echo no | avdmanager create avd -n test -k "\"$system_images"\"