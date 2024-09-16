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
	"119.29.29.29"    # 腾讯DNS
	"119.28.28.28"    # 腾讯DNS
	"223.5.5.5"       # 阿里DNS
	"223.6.6.6"       # 阿里DNS
	"180.76.76.76"    # 百度DNS
	# "180.184.1.1"     # 字节跳动DNS
	# "180.184.2.2"     # 字节跳动DNS
	# "101.226.4.6"     # 360安全DNS
	# "218.30.118.6"    # 360安全DNS
	# "123.125.81.6"    # 360安全DNS
	# "140.207.198.6"   # 360安全DNS
	"117.50.10.10"    # OneDNS
	"52.80.52.52"     # OneDNS
	"114.114.114.114" # 114DNS
	"114.114.115.115" # 114DNS
	# "1.2.4.8"         # CNNIC DNS
	# "210.2.4.8"       # CNNIC DNS
	# "101.101.101.101" # TWNIC DNS
	# "101.102.103.104" # TWNIC DNS
	# "168.95.1.1"      # HiNet DNS
	# "168.95.192.1"    # HiNet DNS
	"8.8.8.8"         # Google DNS
	"8.8.4.4"         # Google DNS
	"1.1.1.1"         # Cloudflare DNS
	"1.0.0.1"         # Cloudflare DNS
	# "9.9.9.9"         # Quad9 DNS
	# "149.112.112.112" # Quad9 DNS
	# "185.222.222.222" # DNS.SB
	# "45.11.45.11"     # DNS.SB
	# "208.67.222.222"  # OpenDNS
	# "208.67.220.220"  # OpenDNS
	# "77.88.8.8"       # Yandex DNS
	# "77.88.8.1"       # Yandex DNS
	# "8.26.56.26"      # COMODO SecureDNS
	# "8.20.247.20"     # COMODO SecureDNS
	# "64.6.64.6"       # Neustar UltraDNS
	# "64.6.65.6"       # Neustar UltraDNS
	# "94.140.14.14"    # AdGuard DNS
	# "94.140.15.15"    # AdGuard DNS
	# "80.80.80.80"     # Freenom World DNS
	# "80.80.81.81"     # Freenom World DNS
)

dns_servers_ipv6=(
	"2402:4e00::"            # 腾讯DNS
	"2402:4e00:1::"          # 腾讯DNS
	"2400:3200::1"           # 阿里DNS
	"2400:3200:baba::1"      # 阿里DNS
	# "240e:4c:4008::1"        # 中国电信IPv6 DNS
	# "240e:4c:4808::1"        # 中国电信IPv6 DNS
	# "240e:1f:1::1"           # 中国电信IPv6 DNS
	# "240e:1f:1::33"          # 中国电信IPv6 DNS
	# "240e:4e:800::66"        # 中国电信IPv6 DNS
	# "240e:4e::66"            # 中国电信IPv6 DNS
	# "240e:56:4000:8000::69"  # 中国电信IPv6 DNS
	# "240e:56:4000::218"      # 中国电信IPv6 DNS
	# "240e:d:0:100::6"        # 中国电信IPv6 DNS
	# "240e:f:a::6"            # 中国电信IPv6 DNS
	# "240e:46:4088::4088"     # 中国电信IPv6 DNS
	# "240e:46:4888::4888"     # 中国电信IPv6 DNS
	# "240e:4a:4400:3::67"     # 中国电信IPv6 DNS
	# "240e:4a:4400:3::167"    # 中国电信IPv6 DNS
	# "240e:45::6666"          # 中国电信IPv6 DNS
	# "240e:45::8888"          # 中国电信IPv6 DNS
	# "2408:8899::8"           # 中国联通IPv6 DNS
	# "2408:8888::8"           # 中国联通IPv6 DNS
	# "2408:8000::8"           # 中国联通IPv6 DNS
	# "2408:8000:c000::8888"   # 中国联通IPv6 DNS
	# "2409:8088::a"           # 中国移动IPv6 DNS
	# "2409:8088::b"           # 中国移动IPv6 DNS
	# "2409:8030:2000::1"      # 中国移动IPv6 DNS
	# "2409:8030:2000::2"      # 中国移动IPv6 DNS
	# "2409:805e:2000::6666"   # 中国移动IPv6 DNS
	# "2409:805e:2000::8888"   # 中国移动IPv6 DNS
	# "2409:8008:2000::1"      # 中国移动IPv6 DNS
	# "2409:8008:2000:100::1"  # 中国移动IPv6 DNS
	# "2409:8057:2000:2::8"    # 中国移动IPv6 DNS
	# "2409:8057:2000:6::8"    # 中国移动IPv6 DNS
	"2001:4860:4860::8888"   # Google IPv6 DNS
	"2001:4860:4860::8844"   # Google IPv6 DNS
	"2606:4700:4700::1111"   # Cloudflare IPv6 DNS
	"2606:4700:4700::1001"   # Cloudflare IPv6 DNS
	# "2620:fe::fe"            # Quad9 IPv6 DNS
	# "2620:fe::9"             # Quad9 IPv6 DNS
	# "2620:fe::fe:9"          # Quad9 IPv6 DNS
	# "2a09::"                 # DNS.SB IPv6 DNS
	# "2a11::"                 # DNS.SB IPv6 DNS
	# "2620:119:35::35"        # Cisco OpenDNS IPv6 DNS
	# "2620:119:53::53"        # Cisco OpenDNS IPv6 DNS
	# "2a02:6b8::feed:0ff"     # Yandex IPv6 DNS
	# "2a02:6b8:0:1::feed:0ff" # Yandex IPv6 DNS
	# "2620:74:1b::1:1"        # Neustar UltraDNS IPv6 DNS
	# "2620:74:1c::2:2"        # Neustar UltraDNS IPv6 DNS
	# "2610:a1:1018::2"        # Neustar UltraDNS IPv6 DNS
	# "2610:a1:1019::2"        # Neustar UltraDNS IPv6 DNS
	# "2610:a1:1018::3"        # Neustar UltraDNS IPv6 DNS
	# "2610:a1:1019::3"        # Neustar UltraDNS IPv6 DNS
	# "2a10:50c0::ad1:ff"      # AdGuard IPv6 DNS
	# "2a10:50c0::ad2:ff"      # AdGuard IPv6 DNS
	# "2001:de4::101"          # TWNIC IPv6 DNS
	# "2001:de4::102"          # TWNIC IPv6 DNS
	# "2001:b000:168::1"       # HiNet 中华电信 IPv6 DNS
	# "2001:b000:168::2"       # HiNet 中华电信 IPv6 DNS
	# "80.80.80.80"            # Freenom World DNS
	# "80.80.81.81"            # Freenom World DNS
)

# 测试DNS服务器响应时间
test_dns() {
  local ip=$1
  local count=3
  local delay=0
  for ((i=0; i<$count; i++)); do
    start=$(date +%s%N)
    dig @${ip} cdnster.net > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      return 1
    fi
    end=$(date +%s%N)
    duration=$((end-start))
    delay=$((delay+duration))
  done
  # 计算平均延迟（毫秒）
  echo "$((delay/count/1000000)) $ip"
}

# 测试并获取最优的2个DNS服务器
get_best_dns_servers() {
  local -n dns_servers=$1
  local results=()

  for server in "${dns_servers[@]}"; do
    result=$(test_dns $server)
    if [ $? -eq 0 ]; then
      results+=("$result")
    fi
  done

  # 返回最优的2个DNS服务器
  printf "%s\n" "${results[@]}" | sort -n | head -n 2
}

# 获取最优的IPv4和IPv6 DNS服务器
echo "测试IPv4 DNS服务器..."
best_ipv4_servers=$(get_best_dns_servers dns_servers_ipv4)

echo "最优的2个IPv4 DNS服务器:"
echo "$best_ipv4_servers"

echo "测试IPv6 DNS服务器..."
best_ipv6_servers=$(get_best_dns_servers dns_servers_ipv6)

echo "最优的2个IPv6 DNS服务器:"
echo "$best_ipv6_servers"

# 修改系统的DNS设置
update_dns() {
  local best_servers="$1"
  local version="$2"

  echo -e "设置${version} DNS服务器为: \n$best_servers"
  if [ "$version" == "IPv4" ]; then
    # 只使用第一个最优的DNS服务器
    echo -e "nameserver $(echo "$best_servers" | awk 'NR==1{print $2}')" > /etc/resolv.conf
  elif [ "$version" == "IPv6" ]; then
    # 在IPv4 DNS服务器的基础上添加第一个最优的IPv6 DNS服务器
    echo -e "nameserver $(echo "$best_servers" | awk 'NR==1{print $2}')" >> /etc/resolv.conf
  fi
}

# 更新DNS设置
if [ -n "$best_ipv4_servers" ]; then
  update_dns "$best_ipv4_servers" "IPv4"
fi

if [ -n "$best_ipv6_servers" ]; then
  update_dns "$best_ipv6_servers" "IPv6"
fi

echo "DNS服务器已更新。"
