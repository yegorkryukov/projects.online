#!/bin/sh

INSTALLED=$(opkg list-installed)

for a in $(opkg print-architecture | awk '{print $2}'); do
	case "$a" in
		all|noarch)
			;;
		aarch64_armv8-a|aarch64_cortex-a53|aarch64_cortex-a72|aarch64_generic|arm_arm926ej-s|arm_arm1176jzf-s_vfp|arm_cortex-a5|arm_cortex-a5_neon-vfpv4|arm_cortex-a5_vfpv4|arm_cortex-a7_neon-vfpv4|arm_cortex-a8_vfpv3|arm_cortex-a9|arm_cortex-a9_neon|arm_cortex-a9_vfpv3|arm_cortex-a15_neon-vfpv4|arm_cortex-a53_neon-vfpv4|arm_fa526|arm_mpcore|arm_mpcore_vfp|arm_xscale|armeb_xscale|i386_pentium|i386_pentium4|mips64_octeon|mips_24kc|mips_mips32|mipsel_24kc|mipsel_24kc_24kf|mipsel_74kc|mipsel_mips32|powerpc_464fp|powerpc_8540|x86_64)
			ARCH=${a}
			;;
		*)
			echo "Architecture not supported."
			exit 0
			;;
	esac
done

echo -e "\nTarget Arch:\033[32m $ARCH \033[0m\n"

if !(grep -q "openwrt_dist" /etc/opkg/customfeeds.conf); then
	wget http://openwrt-dist.sourceforge.net/packages/openwrt-dist.pub
	opkg-key add openwrt-dist.pub
	echo "src/gz openwrt_dist http://openwrt-dist.sourceforge.net/packages/base/$ARCH" >>/etc/opkg/customfeeds.conf
	echo "src/gz openwrt_dist_luci http://openwrt-dist.sourceforge.net/packages/luci" >>/etc/opkg/customfeeds.conf
fi

opkg update

if echo "$INSTALLED" | grep -q "luci"; then
	LuCI=yes
fi

read -p "Install the ChinaDNS [Y/n]?" INS_CD
read -p "Install the DNS-Forwarder [Y/n]?" INS_DF
read -p "Install the shadowsocks-libev [Y/n]?" INS_SS
read -p "Install the iptables-mod-tproxy [Y/n]?" INS_IP

if echo ${INS_CD} | grep -qi "^y"; then
	opkg install ChinaDNS
	if [ "$LuCI" = "yes" ]; then
		opkg install luci-app-chinadns
	fi
fi

if echo ${INS_DF} | grep -qi "^y"; then
	opkg install dns-forwarder
	if [ "$LuCI" = "yes" ]; then
		opkg install luci-app-dns-forwarder
	fi
fi

if echo ${INS_SS} | grep -qi "^y"; then
	opkg install shadowsocks-libev
	if [ "$LuCI" = "yes" ]; then
		opkg install luci-app-shadowsocks
	fi
fi

if echo ${INS_IP} | grep -qi "^y"; then
	opkg install iptables-mod-tproxy
fi

