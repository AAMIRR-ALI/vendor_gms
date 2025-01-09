#!/bin/bash
#
# Copyright (C) 2024 The risingOS Android Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=common
VENDOR=gms

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

{
    echo 'TARGET_CORE_GMS ?= false'
    echo 'ifeq ($(strip $(TARGET_CORE_GMS)),true)'
    echo 'PRODUCT_PACKAGES += \'
    echo '    DeviceIntelligenceNetworkPrebuilt \'
    echo '    DevicePersonalizationPrebuiltPixel2020 \'
    echo '    AICorePrebuilt \'
    echo '    GoogleExtShared \'
    echo '    GoogleContacts \'
    echo '    GoogleDialer \'
    echo '    PrebuiltBugle \'
    echo '    Phonesky \'
    echo '    PrebuiltGmsCoreSc \'
    echo '    PrebuiltGmsCoreSc_AdsDynamite \'
    echo '    PrebuiltGmsCoreSc_CronetDynamite \'
    echo '    PrebuiltGmsCoreSc_DynamiteLoader \'
    echo '    PrebuiltGmsCoreSc_DynamiteModulesA \'
    echo '    PrebuiltGmsCoreSc_DynamiteModulesC \'
    echo '    PrebuiltGmsCoreSc_GoogleCertificates \'
    echo '    PrebuiltGmsCoreSc_MapsDynamite \'
    echo '    PrebuiltGmsCoreSc_MeasurementDynamite \'
    echo '    AndroidPlatformServices \'
    echo '    MlkitBarcodeUIPrebuilt \'
    echo '    VisionBarcodePrebuilt \'
    echo '    LocationHistoryPrebuilt \'
    echo '    AndroidPlatformServices \'
    echo '    GoogleServicesFramework \'
    echo '    PartnerSetupPrebuilt \'
    echo '    PixelSetupWizard \'
    echo '    SetupWizardPrebuilt \'
    echo '    GoogleRestorePrebuilt \'
    echo '    ConfigUpdater \'
    echo '    PixelThemesStub \'
    echo '    SettingsIntelligenceGooglePrebuilt \'
    echo '    WellbeingPrebuilt \'
    echo '    DreamlinerPrebuilt \'
    echo '    DreamlinerUpdater \'
    echo '    GoogleOneTimeInitializer'

    echo ''
    echo 'ifeq ($(strip $(TARGET_CORE_GMS_EXTRAS)),true)'
    echo 'PRODUCT_PACKAGES += \'
    echo '    Photos \'
    echo '    MarkupGoogle \'
    echo '    LatinIMEGooglePrebuilt \'
    echo '    PrebuiltDeskClockGoogle \'
    echo '    CalculatorGooglePrebuilt \'
    echo '    CalendarGooglePrebuilt \'
    echo '    WallpaperEmojiPrebuilt \'
    echo '    AiWallpapers \'
    echo '    Velvet'
    echo 'endif'
    echo ''
    echo 'else'
    echo 'PRODUCT_PACKAGES += \'
} | sed '/^PRODUCT_PACKAGES/r /dev/stdin' "${MY_DIR}/${DEVICE}/common-vendor.mk" > "${MY_DIR}/${DEVICE}/common-vendor.mk.tmp" && mv "${MY_DIR}/${DEVICE}/common-vendor.mk.tmp" "${MY_DIR}/${DEVICE}/common-vendor.mk"

sed -i '0,/^PRODUCT_PACKAGES +=/{/^PRODUCT_PACKAGES +=/d}' "${MY_DIR}/${DEVICE}/common-vendor.mk"

sed -i '/com\.google\.android\.dialer\.support\(\.xml\)\{0,1\}$/a \ \nendif' "${MY_DIR}/${DEVICE}/common-vendor.mk"
