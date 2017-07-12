# ====================================================================== #
# Android SDK Docker Image
# ====================================================================== #

# Base image
# ---------------------------------------------------------------------- #
FROM ubuntu:16.04

# Copy needed files
#----------------------------------------------------------------------- #
COPY ./files/VERSION /
# COPY ./files/create-component-file.sh /

# Author
# ---------------------------------------------------------------------- #
LABEL maintainer "thyrlian@gmail.com"

# support multiarch: i386 architecture
# install Java
# install essential tools
# install Qt
RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install -y libncurses5:i386 libc6:i386 libstdc++6:i386 lib32gcc1 lib32ncurses5 lib32z1 zlib1g:i386 && \
    apt-get install -y --no-install-recommends openjdk-8-jdk && \
    apt-get install -y git wget zip && \
    apt-get install -y qt5-default

# download and install Gradle
ENV GRADLE_VERSION 4.0
RUN cd /opt && \
    wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip gradle*.zip && \
    ls -d */ | sed 's/\/*$//g' | xargs -I{} mv {} gradle && \
    rm gradle*.zip

# download and install Android SDK
RUN mkdir -p /opt/android-sdk && cd /opt/android-sdk && \
    wget -q $(wget -q -O- 'https://developer.android.com/sdk' | \
    grep -o "\"https://.*android.*tools.*linux.*\"" | sed "s/\"//g") && \
    unzip *tools*linux*.zip && \
    rm *tools*linux*.zip

# set the environment variables
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV GRADLE_HOME /opt/gradle
ENV ANDROID_HOME /opt/android-sdk
ENV PATH ${PATH}:${GRADLE_HOME}/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/tools
# temporary workaround for issue https://issuetracker.google.com/issues/37137213
ENV LD_LIBRARY_PATH ${ANDROID_HOME}/emulator/lib64/qt/lib

# accept the license agreements of the SDK components
RUN ANDROID_LICENSES="$ANDROID_HOME/licenses" && \
    mkdir $ANDROID_LICENSES && \
    echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > $ANDROID_LICENSES/android-sdk-license && \
    echo 84831b9409646a918e30573bab4c9c91346d8abd > $ANDROID_LICENSES/android-sdk-preview-license && \
    echo d975f751698a77b662f1254ddbeed3901e976f5a > $ANDROID_LICENSES/intel-android-extra-license

# Create file for installing android components
RUN VERSION=$(cat /VERSION) && \
    MAJOR="$(echo $VERSION | cut -d '.' -f 1)" && \
    echo "version :$MAJOR" && \
    echo "platforms=\"platforms;android-${MAJOR}\"\n \
    build_tools=\"build-tools;$VERSION\"\n \
    extras=\"extras;android;m2repository\"\n \
    platform_tools="platform-tools"\n \
    tools="tools"\n \
    system_images=\"system-images;android-${MAJOR};google_apis;armeabi-v7a\"\n \
    \n" \
    >> /android-components-versions.sh && \
    chmod +x /android-components-versions.sh

# Install Android components
RUN COMPONENTS_FILE=/android-components-versions.sh && \
    . "${COMPONENTS_FILE}" && \
    # Install android components && \
    sdkmanager  "$platforms" "$build_tools" "$extras" "$platform_tools" "$tools" "$system_images" && \
    # Install android emulator called test without a UI && \
    echo no | avdmanager create avd -n test -k "$system_images" | echo no
