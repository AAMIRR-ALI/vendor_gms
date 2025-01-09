#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
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

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" true

# Warning headers and guards
write_headers "arm64"
sed -i 's|TARGET_DEVICE|TARGET_ARCH|g' "${ANDROIDMK}"
sed -i 's|vendor/gms/|vendor/gms/common|g' "${PRODUCTMK}"
sed -i 's|device/gms//setup-makefiles.sh|vendor/gms/setup-makefiles.sh|g' "${ANDROIDBP}" "${ANDROIDMK}" "${BOARDMK}" "${PRODUCTMK}"

{
    echo 'TARGET_CORE_GMS ?= false'
    echo 'ifeq ($(strip $(TARGET_CORE_GMS)),true)'
    echo 'PRODUCT_COPY_FILES += \'
    echo '    vendor/gms/common/proprietary/product/etc/permissions/com.google.android.dialer.support.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/com.google.android.dialer.support.xml \'
    echo '    vendor/gms/common/proprietary/product/etc/permissions/privapp-permissions-google-p.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-google-p.xml \'
    echo '    vendor/gms/common/proprietary/product/etc/permissions/split-permissions-google.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/split-permissions-google.xml \'
    echo '    vendor/gms/common/proprietary/product/etc/security/fsverity/gms_fsverity_cert.der:$(TARGET_COPY_OUT_PRODUCT)/etc/security/fsverity/gms_fsverity_cert.der \'
    echo '    vendor/gms/common/proprietary/product/etc/security/fsverity/play_store_fsi_cert.der:$(TARGET_COPY_OUT_PRODUCT)/etc/security/fsverity/play_store_fsi_cert.der \'
    echo '    vendor/gms/common/proprietary/product/etc/sysconfig/google.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/google.xml \'
    echo '    vendor/gms/common/proprietary/product/etc/sysconfig/google-hiddenapi-package-whitelist.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/google-hiddenapi-package-whitelist.xml \'
    echo '    vendor/gms/common/proprietary/product/etc/sysconfig/google-initial-package-stopped-states.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/google-initial-package-stopped-states.xml \'
    echo '    vendor/gms/common/proprietary/product/etc/sysconfig/google-install-constraints-package-allowlist.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/google-install-constraints-package-allowlist.xml \'
    echo '    vendor/gms/common/proprietary/product/etc/sysconfig/google-staged-installer-whitelist.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/google-staged-installer-whitelist.xml \'
    echo '    vendor/gms/common/proprietary/product/etc/sysconfig/preinstalled-packages-product-pixel-2017-and-newer.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/preinstalled-packages-product-pixel-2017-and-newer.xml \'
    echo '    vendor/gms/common/proprietary/system/etc/permissions/privapp-permissions-google.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-google.xml \'
    echo '    vendor/gms/common/proprietary/system_ext/etc/permissions/privapp-permissions-google-se.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-permissions-google-se.xml'
    echo ''
    echo 'PRODUCT_PACKAGES += \'
    echo '    AndroidPlatformServices \'
    echo '    ConfigUpdater \'
    echo '    GoogleRestorePrebuilt-v603273 \'
    echo '    GoogleServicesFramework \'
    echo '    MlkitBarcodeUIPrebuilt \'
    echo '    Phonesky \'
    echo '    PlayAutoInstallConfig \'
    echo '    PrebuiltGmsCoreVic \'
    echo '    PrebuiltGmsCoreVic_AdsDynamite.uncompressed \'
    echo '    PrebuiltGmsCoreVic_CronetDynamite.uncompressed \'
    echo '    PrebuiltGmsCoreVic_DynamiteLoader.uncompressed \'
    echo '    PrebuiltGmsCoreVic_DynamiteModulesA.uncompressed \'
    echo '    PrebuiltGmsCoreVic_DynamiteModulesC.uncompressed \'
    echo '    PrebuiltGmsCoreVic_GoogleCertificates.uncompressed \'
    echo '    PrebuiltGmsCoreVic_MapsDynamite.uncompressed \'
    echo '    PrebuiltGmsCoreVic_MeasurementDynamite.uncompressed \'
    echo '    SettingsIntelligenceGooglePrebuilt \'
    echo '    VisionBarcodePrebuilt'
    echo ''
    echo '    ifeq ($(strip $(TARGET_CORE_GMS_EXTRAS)),true)'
    echo '    PRODUCT_PACKAGES += \'
    echo '        Velvet \'
    echo '        Photos'
    echo '    endif'
    echo ''
    echo 'else'
    echo ''
} >> "${MY_DIR}/${DEVICE}/common-vendor.mk"

write_makefiles "${MY_DIR}/proprietary-files.txt" true

# Remove trailing backslash
sed -i '/com\.google\.android\.dialer\.support[[:space:]]*\\$/s/[[:space:]]*\\$//' "${MY_DIR}/${DEVICE}/common-vendor.mk"

# Finish
write_footers

# Overlays
echo -e "\ninclude vendor/gms/common/overlays.mk" >> "$PRODUCTMK"

# Gcam
sed -i '/GoogleCamera[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"

# Meet
sed -i '/name: "MeetPrebuilt_20240414"/,/product_specific: true,/s/product_specific: true,/&\n	skip_preprocessed_apk_checks: true,/' "${ANDROIDBP}"

{
    echo 'TARGET_PREBUILT_GOOGLE_CAMERA ?= false'
    echo 'ifeq ($(strip $(TARGET_PREBUILT_GOOGLE_CAMERA)),true)'
    echo 'PRODUCT_PACKAGES += \'
    echo '    GoogleCamera'
    echo 'endif'
    echo ""
} >> "${MY_DIR}/${DEVICE}/common-vendor.mk"

# Pixel Launcher
sed -i '/NexusLauncherRelease[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"

{
    echo 'TARGET_DEFAULT_PIXEL_LAUNCHER ?= false'
    echo 'ifeq ($(strip $(TARGET_DEFAULT_PIXEL_LAUNCHER)),true)'
    echo 'PRODUCT_PACKAGES += \'
    echo '    NexusLauncherRelease'
    echo 'endif'
    echo ""
} >> "${MY_DIR}/${DEVICE}/common-vendor.mk"

# HealthIntelligencePrebuilt
sed -i '/HealthIntelligencePrebuilt[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"

{
    echo 'CURRENT_DEVICE := $(shell echo "$(TARGET_PRODUCT)" | cut -d'\''_'\'' -f 2,3)'
    echo 'ifneq ($(filter $(CURRENT_DEVICE), husky shiba akita caiman komodo tangorpro tokay),)'
    echo 'PRODUCT_PACKAGES += \'
    echo '    HealthIntelligencePrebuilt'
    echo 'endif'
    echo ""
} >> "${MY_DIR}/${DEVICE}/common-vendor.mk"

# GMS Extras
sed -i '/AdaptiveVPNPrebuilt-10307[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/AiWallpapers[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/AvatarPickerGoogle[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/Chrome-Stub[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/CreativeAssistant[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/DreamlinerDreamsPrebuilt_100894[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/DreamlinerPrebuilt_22000020[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/DreamlinerUpdater[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/Drive[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/Maps[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/MeetPrebuilt_20240414[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/Photos[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/PixelAIPrebuilt[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/PixelSupportPrebuilt[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/PixelWallpapers2024[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/PrebuiltGmail[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/RecorderPrebuilt_630544637[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/SatelliteClient[[:space:]]*\\\{0,1\}$/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/SatelliteGatewayPrebuilt[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/TipsPrebuilt_v6.0.0.631744426[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/TrichromeLibrary-Stub[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/vendor\/gms\/common\/proprietary\/product\/app\/Chrome\/Chrome.apk.gz/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/vendor\/gms\/common\/proprietary\/product\/app\/TrichromeLibrary\/TrichromeLibrary.apk.gz/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/vendor\/gms\/common\/proprietary\/product\/app\/WebViewGoogle\/WebViewGoogle.apk.gz/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/VendorSatelliteService[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/WebViewGoogle-Stub[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"
sed -i '/YouTube[[:space:]]*\\/d' "${MY_DIR}/${DEVICE}/common-vendor.mk"

{
    echo 'TARGET_GMS_EXTRAS ?= false'
    echo 'ifeq ($(strip $(TARGET_GMS_EXTRAS)),true)'
    echo 'PRODUCT_COPY_FILES += \'
    echo '    vendor/gms/common/proprietary/product/app/Chrome/Chrome.apk.gz:$(TARGET_COPY_OUT_PRODUCT)/app/Chrome/Chrome.apk.gz \'
    echo '    vendor/gms/common/proprietary/product/app/TrichromeLibrary/TrichromeLibrary.apk.gz:$(TARGET_COPY_OUT_PRODUCT)/app/TrichromeLibrary/TrichromeLibrary.apk.gz \'
    echo '    vendor/gms/common/proprietary/product/app/WebViewGoogle/WebViewGoogle.apk.gz:$(TARGET_COPY_OUT_PRODUCT)/app/WebViewGoogle/WebViewGoogle.apk.gz'
    echo ""
    echo 'PRODUCT_PACKAGES += \'
    echo '    AdaptiveVPNPrebuilt-10307 \'
    echo '    AiWallpapers \'
    echo '    AvatarPickerGoogle \'
    echo '    Chrome-Stub \'
    echo '    CreativeAssistant \'
    echo '    DreamlinerDreamsPrebuilt_100894 \'
    echo '    DreamlinerPrebuilt_22000020 \'
    echo '    DreamlinerUpdater \'
    echo '    Drive \'
    echo '    Maps \'
    echo '    MeetPrebuilt_20240414 \'
    echo '    Photos \'
    echo '    PixelAIPrebuilt \'
    echo '    PixelSupportPrebuilt \'
    echo '    PixelWallpapers2024 \'
    echo '    PrebuiltGmail \'
    echo '    RecorderPrebuilt_630544637 \'
    echo '    SatelliteClient \'
    echo '    SatelliteGatewayPrebuilt \'
    echo '    TipsPrebuilt_v6.0.0.631744426 \'
    echo '    TrichromeLibrary-Stub \'
    echo '    VendorSatelliteService \'
    echo '    WebViewGoogle-Stub \'
    echo '    YouTube'
    echo 'endif'
    echo ""
    echo 'TARGET_GMS_EXTRAS_MINIMAL ?= false'
    echo 'ifeq ($(strip $(TARGET_GMS_EXTRAS_MINIMAL)),true)'
    echo 'PRODUCT_PACKAGES += \'
    echo '    AiWallpapers \'
    echo '    AvatarPickerGoogle \'
    echo '    CreativeAssistant \'
    echo '    PixelAIPrebuilt \'
    echo '    PixelSupportPrebuilt \'
    echo '    SatelliteClient \'
    echo '    SatelliteGatewayPrebuilt \'
    echo '    VendorSatelliteService'
    echo 'endif'
    echo 'endif'
} >> "${MY_DIR}/${DEVICE}/common-vendor.mk"
