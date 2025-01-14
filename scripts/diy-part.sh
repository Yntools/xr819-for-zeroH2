#!/bin/bash

# Function to modify default IP
modify_default_ip() {
    sed -i 's/192.168.1.1/192.168.1.1/g' package/base-files/files/bin/config_generate
}

# Function to add XR819 support
add_xr819_support() {
    echo "Adding XR819 WiFi support..."
    
    # Clone xradio driver repository
    git clone https://github.com/fifteenhex/xradio.git package/kernel/xradio
    
    # Add package definition for xradio driver
    cat > package/kernel/xradio/Makefile <<'EOF'
include $(TOPDIR)/rules.mk

PKG_NAME:=xradio
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/xradio
  SUBMENU:=Wireless Drivers
  TITLE:=XR819 WiFi driver
  DEPENDS:=@TARGET_sunxi +kmod-cfg80211 +kmod-mac80211
  FILES:=$(PKG_BUILD_DIR)/xradio_wlan.ko
  AUTOLOAD:=$(call AutoProbe,xradio_wlan)
endef

define KernelPackage/xradio/description
  WiFi driver for XR819 devices
endef

define Build/Compile
    $(KERNEL_MAKE) M="$(PKG_BUILD_DIR)" modules
endef

$(eval $(call KernelPackage,xradio))
EOF

    # Add kernel config options
    mkdir -p package/kernel/linux/modules
    echo "CONFIG_WLAN_VENDOR_XRADIO=y" >> target/linux/sunxi/config-5.15
    echo "CONFIG_XRADIO_WLAN=m" >> target/linux/sunxi/config-5.15
}

# Function to ensure all necessary wireless packages are included
add_wireless_packages() {
    # Add necessary wireless packages to config
    echo "CONFIG_PACKAGE_kmod-xradio=y" >> .config
    echo "CONFIG_PACKAGE_wireless-regdb=y" >> .config
    echo "CONFIG_PACKAGE_wpad-basic=y" >> .config
    echo "CONFIG_PACKAGE_hostapd-common=y" >> .config
    echo "CONFIG_PACKAGE_wireless-tools=y" >> .config
    echo "CONFIG_PACKAGE_mac80211=y" >> .config
    echo "CONFIG_PACKAGE_cfg80211=y" >> .config
}

# Main process
modify_default_ip
add_xr819_support
add_wireless_packages