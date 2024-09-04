	#!/bin/bash
	# 检查是否以root用户运行
	if [ "$EUID" -ne 0 ]; then
	echo "请以root用户运行此脚本。"
	exit 1
	fi
	# 检查是否安装了dig
	if ! command -v dig > /dev/null; then
	echo "dig未安装。请安装dnsutils (Debian/Ubuntu) 或 bind-utils (Red Hat/CentOS)。"
	exit 1
	fi
	# DNS服务器列表
	dns_servers_ipv4=(
	 "119.29.29.29 (腾讯DNS)"
	 "119.28.28.28 (腾讯DNS)"
	 "223.5.5.5 (阿里DNS)"
	 "223.6.6.6 (阿里DNS)"
	 "180.76.76.76 (百度DNS)"
	 "180.184.1.1 (字节跳动DNS)"
	 "180.184.2.2 (字节跳动DNS)"
	 "101.226.4.6 (360安全DNS)"
	 "218.30.118.6 (360安全DNS)"
	 "123.125.81.6 (360安全DNS)"
	 "140.207.198.6 (360安全DNS)"
	 "117.50.10.10 (OneDNS)"
	 "52.80.52.52 (OneDNS)"
	 "114.114.114.114 (114DNS)"
	 "114.114.115.115 (114DNS)"
	 "1.2.4.8 (CNNIC DNS)"
	 "210.2.4.8 (CNNIC DNS)"
	 "101.101.101.101 (TWNIC DNS)"
	 "101.102.103.104 (TWNIC DNS)"
	 "168.95.1.1 (HiNet DNS)"
	 "168.95.192.1 (HiNet DNS)"
	 "8.8.8.8 (Google DNS)"
	 "8.8.4.4 (Google DNS)"
	 "1.1.1.1 (Cloudflare DNS)"
	 "1.0.0.1 (Cloudflare DNS)"
	 "9.9.9.9 (Quad9 DNS)"
	 "149.112.112.112 (Quad9 DNS)"
	 "185.222.222.222 (DNS.SB)"
	 "45.11.45.11 (DNS.SB)"
	 "208.67.222.222 (OpenDNS)"
	 "208.67.220.220 (OpenDNS)"
	 "77.88.8.8 (Yandex DNS)"
	 "77.88.8.1 (Yandex DNS)"
	 "8.26.56.26 (COMODO SecureDNS)"
	 "8.20.247.20 (COMODO SecureDNS)"
	 "64.6.64.6 (Neustar UltraDNS)"
	 "64.6.65.6 (Neustar UltraDNS)"
	 "94.140.14.14 (AdGuard DNS)"
	 "94.140.15.15 (AdGuard DNS)"
	 "80.80.80.80 (Freenom World DNS)"
	 "80.80.81.81 (Freenom World DNS)"
	)
	dns_servers_ipv6=(
	"2402:4e00:: (腾讯DNS)"
	"2402:4e00:1:: (腾讯DNS)"
	"2400:3200::1 (阿里DNS)"
	"2400:3200:baba::1 (阿里DNS)"
	"240e:4c:4008::1 (中国电信IPv6 DNS)"
	"240e:4c:4808::1 (中国电信IPv6 DNS)"
	"240e:1f:1::1 (中国电信IPv6 DNS)"
	"240e:1f:1::33 (中国电信IPv6 DNS)"
	"240e:4e:800::66 (中国电信IPv6 DNS)"
	"240e:4e::66 (中国电信IPv6 DNS)"
	"240e:56:4000:8000::69 (中国电信IPv6 DNS)"
	"240e:56:4000::218 (中国电信IPv6 DNS)"
	"240e:d:0:100::6 (中国电信IPv6 DNS)"
	"240e:f:a::6 (中国电信IPv6 DNS)"
	"240e:46:4088::4088 (中国电信IPv6 DNS)"
	"240e:46:4888::4888 (中国电信IPv6 DNS)"
	"240e:4a:4400:3::67 (中国电信IPv6 DNS)"
	"240e:4a:4400:3::167 (中国电信IPv6 DNS)"
	"240e:45::6666 (中国电信IPv6 DNS)"
	"240e:45::8888 (中国电信IPv6 DNS)"
	"2408:8899::8 (中国联通IPv6 DNS)"
	"2408:8888::8 (中国联通IPv6 DNS)"
	"2408:8000::8 (中国联通IPv6 DNS)"
	"2408:8000:c000::8888 (中国联通IPv6 DNS)"
	"2409:8088::a (中国移动IPv6 DNS)"
	"2409:8088::b (中国移动IPv6 DNS)"
	"2409:8030:2000::1 (中国移动IPv6 DNS)"
	"2409:8030:2000::2 (中国移动IPv6 DNS)"
	"2409:805e:2000::6666 (中国移动IPv6 DNS)"
	"2409:805e:2000::8888 (中国移动IPv6 DNS)"
	"2409:8008:2000::1 (中国移动IPv6 DNS)"
	"2409:8008:2000:100::1 (中国移动IPv6 DNS)"
	"2409:8057:2000:2::8 (中国移动IPv6 DNS)"
	"2409:8057:2000:6::8 (中国移动IPv6 DNS)"
	"2001:4860:4860::8888 (Google IPv6 DNS)"
	"2001:4860:4860::8844 (Google IPv6 DNS)"
	"2606:4700:4700::1111 (Cloudflare IPv6 DNS)"
	"2606:4700:4700::1001 (Cloudflare IPv6 DNS)"
	"2620:fe::fe (Quad9 IPv6 DNS)"
	"2620:fe::9 (Quad9 IPv6 DNS)"
	"2620:fe::fe:9 (Quad9 IPv6 DNS)"
	"2a09:: (DNS.SB IPv6 DNS)"
	"2a11:: (DNS.SB IPv6 DNS)"
	"2620:119:35::35 (Cisco OpenDNS IPv6 DNS)"
	"2620:119:53::53 (Cisco OpenDNS IPv6 DNS)"
	"2a02:6b8::feed:0ff (Yandex IPv6 DNS)"
	"2a02:6b8:0:1::feed:0ff (Yandex IPv6 DNS)"
	"2620:74:1b::1:1 (Neustar UltraDNS IPv6 DNS)"
	"2620:74:1c::2:2 (Neustar UltraDNS IPv6 DNS)"
	"2610:a1:1018::2 (Neustar UltraDNS IPv6 DNS)"
	"2610:a1:1019::2 (Neustar UltraDNS IPv6 DNS)"
	"2610:a1:1018::3 (Neustar UltraDNS IPv6 DNS)"
	"2610:a1:1019::3 (Neustar UltraDNS IPv6 DNS)"
	"2a10:50c0::ad1:ff (AdGuard IPv6 DNS)"
	"2a10:50c0::ad2:ff (AdGuard IPv6 DNS)"
	"2001:de4::101 (TWNIC IPv6 DNS)"
	"2001:de4::102 (TWNIC IPv6 DNS)"
	"2001:b000:168::1 (HiNet 中华电信 IPv6 DNS)"
	"2001:b000:168::2 (HiNet 中华电信 IPv6 DNS)"
	"80.80.80.80 (Freenom World DNS)"
	"80.80.81.81 (Freenom World DNS)"
	)
	# 测试DNS服务器响应时间
	test_dns() {
	local ip=$1
	local count=3
	local delay=0
	for ((i=0; i<count; i++)); do
	  start=$(date +%s%N)
	  dig @${ip} cdnster.net > /dev/null
	  if [ $? -ne 0 ]; then
	    echo "使用${ip}解析cdnster.net失败"
	    return 1
	  fi
	  end=$(date +%s%N)
	  duration=$((end-start))
	  delay=$((delay+duration))
	done
	echo "$((delay/count/1000000)) ms" $ip
	}
	# 测试IPv4 DNS服务器
	echo "测试IPv4 DNS服务器..."
	ipv4_results=()
	for server in "${dns_servers_ipv4[@]}"; do
	result=$(test_dns $server)
	ipv4_results+=("$result")
	done
	# 排序并显示前两个最优的IPv4 DNS服务器
	echo "最优的2个IPv4 DNS服务器:"
	printf "%s\n" "${ipv4_results[@]}" | sort -n | head -n 2
	# 测试IPv6 DNS服务器
	echo "测试IPv6 DNS服务器..."
	ipv6_results=()
	for server in "${dns_servers_ipv6[@]}"; do
	result=$(test_dns $server)
	ipv6_results+=("$result")
	done
	# 排序并显示前两个最优的IPv6 DNS服务器
	echo "最优的2个IPv6 DNS服务器:"
	printf "%s\n" "${ipv6_results[@]}" | sort -n | head -n 2
	# 修改系统的DNS设置
	update_dns() {
	local ip=$1
	local version=$2
	if [ "$version" == "ipv4" ]; then
	  echo "设置IPv4 DNS服务器为: $ip"
	  echo "nameserver $ip" > /etc/resolv.conf
	elif [ "$version" == "ipv6" ]; then
	  echo "设置IPv6 DNS服务器为: $ip"
	  echo "nameserver $ip" >> /etc/resolv.conf
	fi
	}
	# 获取最优的DNS服务器IP地址
	optimal_ipv4=$(printf "%s\n" "${ipv4_results[@]}" | sort -n | head -n 1 | awk '{print $2}')
	optimal_ipv6=$(printf "%s\n" "${ipv6_results[@]}" | sort -n | head -n 1 | awk '{print $2}')
	# 更新DNS设置
	update_dns $optimal_ipv4 "ipv4"
	update_dns $optimal_ipv6 "ipv6"
	echo "DNS服务器已更新。"
