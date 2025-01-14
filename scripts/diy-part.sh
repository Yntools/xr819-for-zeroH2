#!/bin/bash

# Function to modify default IP (if needed)
modify_default_ip() {
    sed -i 's/192.168.1.1/192.168.1.1/g' package/base-files/files/bin/config_generate
}

# Function to add XR819 support
add_xr819_support() {
    echo "Adding XR819 WiFi support..."
    
    # Clone xradio driver repository
    git clone https://github.com/Yntools/xr819.git package/kernel/xradio
    
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

    # Add kernel config options for 6.1 kernel
    echo "CONFIG_WLAN_VENDOR_XRADIO=y" >> target/linux/sunxi/config-6.1
    echo "CONFIG_XRADIO_WLAN=m" >> target/linux/sunxi/config-6.1
}

# Function to add wireless configuration
add_wireless_config() {
    # Basic configuration
    cat >> .config <<EOF
CONFIG_TARGET_sunxi=y
CONFIG_TARGET_sunxi_cortexa7=y
CONFIG_TARGET_sunxi_cortexa7_DEVICE_xunlong_orangepi-zero=y

# Kernel configuration
CONFIG_KERNEL_KERNEL_VERSION="6.1"
CONFIG_LINUX_6_1=y

# XR819 and wireless support
CONFIG_PACKAGE_kmod-xradio=y
CONFIG_PACKAGE_wireless-regdb=y
CONFIG_PACKAGE_wpad-basic=y
CONFIG_PACKAGE_kmod-cfg80211=y
CONFIG_PACKAGE_kmod-mac80211=y
CONFIG_PACKAGE_MAC80211_MESH=y
CONFIG_PACKAGE_REGDB_WIRELESS=y

# Basic system utilities
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_autocore=y
CONFIG_PACKAGE_autocore-arm=y
CONFIG_PACKAGE_automount=y
CONFIG_PACKAGE_ipv6helper=y

# LuCI configuration
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-app-firewall=y
CONFIG_PACKAGE_luci-app-opkg=y
CONFIG_PACKAGE_luci-theme-bootstrap=y
CONFIG_PACKAGE_luci-app-wifi=y
EOF
}

# Main process
modify_default_ip
add_xr819_support
add_wireless_config