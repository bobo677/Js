#!/bin/bash
clear

### 基础部分 ###
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 默认开启 Irqbalance
sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config
# 移除 SNAPSHOT 标签
sed -i 's,-SNAPSHOT,,g' include/version.mk
sed -i 's,-SNAPSHOT,,g' package/base-files/image-config.in

### 获取额外的基础软件包 ###

# igb-intel驱动
svn export https://github.com/coolsnowwolf/lede/trunk/package/lean/igb-intel package/new/igb-intel

# 广告过滤 AdGuard
#svn export https://github.com/Lienol/openwrt/trunk/package/diy/luci-app-adguardhome package/new/luci-app-adguardhome
git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/new/luci-app-adguardhome
rm -rf ./feeds/packages/net/adguardhome
svn export https://github.com/openwrt/packages/trunk/net/adguardhome feeds/packages/net/adguardhome
#sed -i '/\t)/a\\t$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/AdGuardHome' ./feeds/packages/net/adguardhome/Makefile
sed -i '/init/d' feeds/packages/net/adguardhome/Makefile

# Argon 主题
git clone -b master --depth 1 https://github.com/jerrykuku/luci-theme-argon.git package/new/luci-theme-argon
#git clone -b luci-21 --depth 1 https://github.com/jjm2473/luci-theme-argon.git package/new/luci-theme-argon
#wget -P package/new/luci-theme-argon/htdocs/luci-static/argon/background/ https://github.com/QiuSimons/OpenWrt-Add/raw/master/5808303.jpg
rm -rf ./package/new/luci-theme-argon/htdocs/luci-static/argon/background/README.md
#pushd package/new/luci-theme-argon
#git checkout 3b15d06
#popd
git clone -b master --depth 1 https://github.com/jerrykuku/luci-app-argon-config.git package/new/luci-app-argon-config

# MAC 地址与 IP 绑定
svn export https://github.com/immortalwrt/luci/trunk/applications/luci-app-arpbind feeds/luci/applications/luci-app-arpbind
ln -sf ../../../feeds/luci/applications/luci-app-arpbind ./package/feeds/luci/luci-app-arpbind

# 定时重启
svn export https://github.com/coolsnowwolf/luci/trunk/applications/luci-app-autoreboot package/lean/luci-app-autoreboot
# Boost 通用即插即用
svn export https://github.com/QiuSimons/slim-wrt/branches/main/slimapps/application/luci-app-boostupnp package/new/luci-app-boostupnp
rm -rf ./feeds/packages/net/miniupnpd
svn export https://github.com/openwrt/packages/trunk/net/miniupnpd feeds/packages/net/miniupnpd
pushd feeds/packages
wget -qO- https://github.com/openwrt/packages/commit/785bbcb.patch | patch -p1
wget -qO- https://github.com/openwrt/packages/commit/d811cb4.patch | patch -p1
wget -qO- https://github.com/openwrt/packages/commit/9a2da85.patch | patch -p1
wget -qO- https://github.com/openwrt/packages/commit/71dc090.patch | patch -p1
popd
sed -i '/firewall4.include/d' feeds/packages/net/miniupnpd/Makefile
rm -rf ./feeds/luci/applications/luci-app-upnp
#git clone -b main --depth 1 https://github.com/msylgj/luci-app-upnp feeds/luci/applications/luci-app-upnp
svn export https://github.com/openwrt/luci/trunk/applications/luci-app-upnp feeds/luci/applications/luci-app-upnp
pushd feeds/luci
wget -qO- https://github.com/openwrt/luci/commit/0b5fb915.patch | patch -p1
popd

# 流量监管
svn export https://github.com/coolsnowwolf/luci/trunk/applications/luci-app-netdata package/lean/luci-app-netdata

# OpenClash
#wget -qO - https://github.com/openwrt/openwrt/commit/efc8aff.patch | patch -p1
#git clone --single-branch --depth 1 -b dev https://github.com/vernesong/OpenClash.git package/new/luci-app-openclash
svn export https://github.com/vernesong/OpenClash/branches/dev/luci-app-openclash package/new/luci-app-openclash

# 清理内存
svn export https://github.com/coolsnowwolf/luci/trunk/applications/luci-app-ramfree package/lean/luci-app-ramfree
# ServerChan 微信推送
git clone -b master --depth 1 https://github.com/tty228/luci-app-serverchan.git package/new/luci-app-serverchan

# KMS 激活助手
svn export https://github.com/coolsnowwolf/luci/trunk/applications/luci-app-vlmcsd package/lean/luci-app-vlmcsd
svn export https://github.com/coolsnowwolf/packages/trunk/net/vlmcsd package/lean/vlmcsd

# 网络唤醒
svn export https://github.com/zxlhhyccc/bf-package-master/trunk/zxlhhyccc/luci-app-services-wolplus package/new/luci-app-services-wolplus
# 流量监视
git clone -b master --depth 1 https://github.com/brvphoenix/wrtbwmon.git package/new/wrtbwmon
git clone -b master --depth 1 https://github.com/brvphoenix/luci-app-wrtbwmon.git package/new/luci-app-wrtbwmon

### 最后的收尾工作 ###

# 生成默认配置及缓存
rm -rf .config

echo '
CONFIG_RESERVE_ACTIVEFILE_TO_PREVENT_DISK_THRASHING=y
CONFIG_RESERVE_ACTIVEFILE_KBYTES=65536
CONFIG_RESERVE_INACTIVEFILE_TO_PREVENT_DISK_THRASHING=y
CONFIG_RESERVE_INACTIVEFILE_KBYTES=65536
CONFIG_RANDOM_DEFAULT_IMPL=y
CONFIG_LRNG=y
CONFIG_LRNG_SHA256=y
CONFIG_LRNG_RCT_CUTOFF=31
CONFIG_LRNG_APT_CUTOFF=325
CONFIG_LRNG_CPU=y
CONFIG_LRNG_CPU_FULL_ENT_MULTIPLIER=1
CONFIG_LRNG_CPU_ENTROPY_RATE=8
CONFIG_LRNG_DRNG_CHACHA20=y
CONFIG_LRNG_DFLT_DRNG_CHACHA20=y
CONFIG_NFSD=y
' >>./target/linux/generic/config-5.15


