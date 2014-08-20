#
# Copyright (C) 2013-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lxc
PKG_VERSION:=1.0.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://linuxcontainers.org/downloads/
PKG_MD5SUM:=55873b1411a606397309aa6c4c4263b3

PKG_BUILD_DEPENDS:=lua
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

LXC_APPLETS_BIN += \
	attach autostart cgroup clone config console create destroy execute \
	freeze info monitor snapshot start stop unfreeze unshare usernsexec wait

LXC_APPLETS_LIB += \
	monitord user-nic

LXC_SCRIPTS += \
	checkconfig ls top

DEPENDS_APPLETS = +libpthread +libcap +liblxc

DEPENDS_top = +lxc-lua +luafilesystem @BROKEN


define Package/lxc/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=LXC userspace tools
  URL:=http://lxc.sourceforge.net/
  MAINTAINER:=Luka Perkov <luka@openwrt.org>
endef

define Package/lxc
  $(call Package/lxc/Default)
  MENU:=1
endef

define Package/lxc/description
 LXC is the userspace control package for Linux Containers, a lightweight
 virtual system mechanism sometimes described as "chroot on steroids".
endef

define Package/lxc-common
  $(call Package/lxc/Default)
  TITLE:=LXC common files
  DEPENDS:= lxc
endef

define Package/lxc-hooks
  $(call Package/lxc/Default)
  TITLE:=LXC virtual machine hooks
  DEPENDS:= lxc
endef

define Package/lxc-templates
  $(call Package/lxc/Default)
  TITLE:=LXC virtual machine templates
  DEPENDS:= lxc @BROKEN
endef

define Package/liblxc
  $(call Package/lxc/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=LXC userspace library
  DEPENDS:= lxc +libcap +libpthread
endef

define Package/lxc-lua
  $(call Package/lxc/Default)
  TITLE:=LXC Lua bindings
  DEPENDS:= lxc +liblua +liblxc +luafilesystem
endef

define Package/lxc-init
  $(call Package/lxc/Default)
  TITLE:=LXC Lua bindings
  DEPENDS:= lxc +liblxc
endef

CONFIGURE_ARGS += \
	--disable-apparmor \
	--disable-doc \
	--disable-examples \
	--disable-seccomp
	--enable-lua=yes \
	--with-lua-pc="$(STAGING_DIR)/usr/lib/pkgconfig/lua.pc" \

MAKE_FLAGS += \
	LUA_INSTALL_CMOD="/usr/lib/lua" \
	LUA_INSTALL_LMOD="/usr/lib/lua"

define Build/Configure
	( cd $(PKG_BUILD_DIR); ./autogen.sh );
	$(call Build/Configure/Default)
endef


define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/lxc/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/lxc/* \
		$(1)/usr/include/lxc/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/liblxc.so* \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/lxc.pc \
		$(1)/usr/lib/pkgconfig/
endef


define Package/lxc/install
	true
endef

define Package/lxc-common/conffiles
/etc/lxc/default.conf
/etc/lxc/lxc.conf
endef

define Package/lxc-common/install
	$(INSTALL_DIR) $(1)/usr/lib/lxc/rootfs
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/lxc/rootfs/README \
		$(1)/usr/lib/lxc/rootfs/

	$(INSTALL_DIR) $(1)/usr/share/lxc
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/share/lxc/lxc.functions \
		$(1)/usr/share/lxc/

	$(INSTALL_DIR) $(1)/etc/lxc/
	$(CP) \
		$(PKG_INSTALL_DIR)/etc/lxc/default.conf \
		$(1)/etc/lxc/
endef

define Package/lxc-hooks/install
	$(INSTALL_DIR) $(1)/usr/share/lxc/hooks
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/share/lxc/hooks/mountcgroups \
		$(1)/usr/share/lxc/hooks/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/share/lxc/hooks/mountecryptfsroot \
		$(1)/usr/share/lxc/hooks/
endef

define Package/lxc-templates/install
	$(INSTALL_DIR) $(1)/usr/share/lxc/templates/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/share/lxc/templates/lxc-* \
		$(1)/usr/share/lxc/templates/
endef

define Package/liblxc/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/liblxc.so* \
		$(1)/usr/lib/
endef

define Package/lxc-lua/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/share/lua/5.1/lxc.lua \
		$(1)/usr/lib/lua/
	$(INSTALL_DIR) $(1)/usr/lib/lua/lxc
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/lua/5.1/lxc/core.so \
		$(1)/usr/lib/lua/lxc/
endef

define Package/lxc-init/install
	$(INSTALL_DIR) $(1)/sbin
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/sbin/init.lxc \
		$(1)/sbin/
endef

define GenPlugin
  define Package/lxc-$(1)
    $(call Package/lxc/Default)
    TITLE:=Utility lxc-$(1) from the LXC userspace tools
    DEPENDS:= lxc +lxc-common $(2) $(DEPENDS_$(1))
  endef

  define Package/lxc-$(1)/install
	$(INSTALL_DIR) $$(1)$(3)
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)$(3)/lxc-$(1) \
		$$(1)$(3)/
  endef

  $$(eval $$(call BuildPackage,lxc-$(1)))
endef


$(eval $(call BuildPackage,lxc))
$(eval $(call BuildPackage,lxc-common))
$(eval $(call BuildPackage,lxc-hooks))
$(eval $(call BuildPackage,lxc-templates))
$(eval $(call BuildPackage,liblxc))
$(eval $(call BuildPackage,lxc-lua))
$(foreach u,$(LXC_APPLETS_BIN),$(eval $(call GenPlugin,$(u),$(DEPENDS_APPLETS),"/usr/bin")))
$(foreach u,$(LXC_APPLETS_LIB),$(eval $(call GenPlugin,$(u),$(DEPENDS_APPLETS),"/usr/lib/lxc")))
$(foreach u,$(LXC_SCRIPTS),$(eval $(call GenPlugin,$(u),,"/usr/bin")))
