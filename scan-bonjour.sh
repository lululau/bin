#!/bin/bash
#
# scan-bonjour.sh — 扫描局域网内所有 Bonjour (mDNS/DNS-SD) 设备与服务
#
# 原理(全部基于 macOS 自带工具, 无第三方依赖):
#   1. dns-sd -B _services._dns-sd._udp local.   枚举网内所有服务类型
#   2. dns-sd -B <服务类型> local.               浏览该类型下的设备实例
#   3. dns-sd -L <实例名> <服务类型> local.       解析实例 -> 主机名 + 端口
#   4. dscacheutil -q host -a name <主机名>      主机名 -> IP
#
# 用法: ./scan-bonjour.sh [--csv|--md] [--by-host]
# 详见: README.bonjour-scan.md

set -u

BROWSE_TYPES_SECS="${BROWSE_TYPES_SECS:-4}"   # 第 1 步监听时长(秒)
BROWSE_SECS="${BROWSE_SECS:-2.5}"             # 第 2 步每类服务监听时长(秒)
LOOKUP_SECS="${LOOKUP_SECS:-1.5}"             # 第 3 步每个实例解析等待(秒)

FORMAT=table
BY_HOST=0

usage() {
  cat <<EOF
用法: $(basename "$0") [--csv|--md] [--by-host]

输出格式:
  (无参数)    对齐表格, 每行一条服务记录(默认)
  --csv       CSV 格式, 适合导入表格/程序处理
  --md        Markdown 表格
  --by-host   按设备分组汇总服务列表, 可与 --md 组合

环境变量(调节监听时长, 网络慢/设备多时调大):
  BROWSE_TYPES_SECS=$BROWSE_TYPES_SECS  枚举服务类型的监听秒数
  BROWSE_SECS=$BROWSE_SECS            浏览每类服务的监听秒数
  LOOKUP_SECS=$LOOKUP_SECS            解析每个实例的等待秒数
EOF
}

for arg in "$@"; do
  case "$arg" in
    --csv)     FORMAT=csv ;;
    --md)      FORMAT=md ;;
    --by-host) BY_HOST=1 ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数: %s\n\n' "$arg" >&2; usage; exit 1 ;;
  esac
done

command -v dns-sd >/dev/null 2>&1 || { echo "错误: 找不到 dns-sd (仅支持 macOS)" >&2; exit 1; }
command -v dscacheutil >/dev/null 2>&1 || { echo "错误: 找不到 dscacheutil (仅支持 macOS)" >&2; exit 1; }

# dns-sd 是持续监听命令: 后台跑 secs 秒, 输出落盘后 kill
run_dnssd() {
  local secs=$1 out=$2; shift 2
  dns-sd "$@" >"$out" 2>&1 &
  local pid=$!
  sleep "$secs"
  kill "$pid" 2>/dev/null
  wait "$pid" 2>/dev/null
}

# 服务类型 -> 可读说明 (未收录的类型回退显示原始标签)
svc_desc() {
  case "$1" in
    _adisk._tcp)          echo "Apple 时间机器/AirDisk 磁盘共享" ;;
    _afpovertcp._tcp)     echo "Mac 文件共享 (AFP)" ;;
    _airplay._tcp)        echo "AirPlay 投屏/视频" ;;
    _apple-mobdev2._tcp)  echo "iPhone/iPad (设备管理)" ;;
    _asquic._udp)         echo "Apple QUIC 中继 (系统)" ;;
    _axis-video._tcp)     echo "网络摄像头 (Axis)" ;;
    _bttremote._tcp)      echo "BetterTouchTool Remote 遥控" ;;
    _companion-link._tcp) echo "苹果设备互联 (Continuity)" ;;
    _continuity._tcp)     echo "苹果连续互通 (Continuity)" ;;
    _daap._tcp)           echo "iTunes 音乐共享 (DAAP)" ;;
    _device-info._tcp)    echo "设备信息" ;;
    _ftp._tcp)            echo "FTP 文件传输" ;;
    _googlecast._tcp)     echo "Google Cast 投屏 (Chromecast)" ;;
    _hap._tcp)            echo "HomeKit 智能配件" ;;
    _http._tcp)           echo "Web 网页服务" ;;
    _https._tcp)          echo "Web 网页服务 (HTTPS)" ;;
    _ipp._tcp)            echo "网络打印机 (IPP)" ;;
    _ipps._tcp)           echo "网络打印机 (IPP over TLS)" ;;
    _matter._tcp|_matterc._udp) echo "Matter 智能家居" ;;
    _nvstream._tcp)       echo "NVIDIA GameStream 串流" ;;
    _pdl-datastream._tcp) echo "打印机数据流" ;;
    _printer._tcp)        echo "网络打印机 (LPD)" ;;
    _raop._tcp)           echo "AirPlay 音频 (RAOP)" ;;
    _rfb._tcp)            echo "屏幕共享 / VNC" ;;
    _remotepairing._tcp)  echo "Apple TV/设备远程配对" ;;
    _rtsp._tcp)           echo "RTSP 视频流" ;;
    _sftp-ssh._tcp)       echo "SFTP 文件传输 (SSH)" ;;
    _sleep-proxy._udp)    echo "Bonjour 睡眠代理" ;;
    _smb._tcp)            echo "Windows 文件共享 (SMB)" ;;
    _spotify-connect._tcp) echo "Spotify Connect" ;;
    _ssh._tcp)            echo "SSH 远程登录" ;;
    _telnet._tcp)         echo "Telnet 远程登录" ;;
    _touch-able._tcp)     echo "iPhone/iPod 同步" ;;
    _uscan._tcp|_uscans._tcp) echo "网络扫描仪" ;;
    _webdav._tcp)         echo "WebDAV 文件共享" ;;
    *)                    printf '%s' "${1%%.*}" | sed 's/^_//' ;;
  esac
}

TMP=$(mktemp -d "${TMPDIR:-/tmp}/bonjour-scan.XXXXXX")
trap 'rm -rf "$TMP"' EXIT

# ---------- 第 1 步: 枚举所有服务类型 ----------
printf '正在枚举 Bonjour 服务类型 (%ss) ...\n' "$BROWSE_TYPES_SECS" >&2
run_dnssd "$BROWSE_TYPES_SECS" "$TMP/types.txt" -B _services._dns-sd._udp local.
# 行格式: <时间戳> <Add|Rmv> <flags> <接口> <域> <_tcp.local.|_udp.local.> <服务类型标签>
awk '$2=="Add" && $6 ~ /^_(tcp|udp)\./ {print $7"."$6}' "$TMP/types.txt" \
  | LC_ALL=C sort -u | grep -v '^_services\.' > "$TMP/types.list"
TYPES_N=$(wc -l < "$TMP/types.list" | tr -d ' ')
if [ "$TYPES_N" -eq 0 ]; then
  echo "未发现任何 Bonjour 服务。可能原因: 设备都在休眠 / 网段隔离(mDNS 未跨 VLAN 转发)" >&2
  exit 1
fi

# ---------- 第 2 步: 逐类浏览设备实例 ----------
: > "$TMP/instances.tsv"
while read -r full; do
  svc=${full%%.*}
  proto=${full#*.}; proto=${proto%%.*}
  run_dnssd "$BROWSE_SECS" "$TMP/browse.txt" -B "${svc}.${proto}" local.
  # 实例名可能含空格, 取第 7 列到行尾
  awk -v svc="$svc" -v proto="$proto" \
    '$2=="Add" && $5=="local." { $1=$2=$3=$4=$5=$6=""; sub(/^ +/,""); print svc"\t"proto"\t"$0 }' \
    "$TMP/browse.txt" >> "$TMP/instances.tsv"
done < "$TMP/types.list"
LC_ALL=C sort -u "$TMP/instances.tsv" > "$TMP/instances.u.tsv"
INST_N=$(wc -l < "$TMP/instances.u.tsv" | tr -d ' ')
ETA=$(awk -v a="$TYPES_N" -v b="$BROWSE_SECS" -v c="$INST_N" -v d="$LOOKUP_SECS" \
  'BEGIN{printf "%d", a*b + c*d}')
printf '发现 %s 种服务类型 / %s 个实例, 正在解析(预计约 %ss)...\n' "$TYPES_N" "$INST_N" "$ETA" >&2

# ---------- 第 3/4 步: 逐个解析 主机名+端口 -> IP ----------
: > "$TMP/data.tsv"   # host|ip|port|service|instance
while IFS=$'\t' read -r svc proto inst; do
  [ -n "$inst" ] || continue
  run_dnssd "$LOOKUP_SECS" "$TMP/lookup.txt" -L "$inst" "${svc}.${proto}" local.
  line=$(grep 'can be reached at' "$TMP/lookup.txt" | head -1)
  host=$(printf '%s' "$line" | sed -n 's/.*can be reached at \([^:]*\):\([0-9][0-9]*\).*/\1/p')
  port=$(printf '%s' "$line" | sed -n 's/.*can be reached at \([^:]*\):\([0-9][0-9]*\).*/\2/p')
  if [ -n "$host" ]; then
    # dscacheutil 可能返回多条记录(本机会同时有 192.168.x.x 和 127.0.0.1), 优先非回环
    hinfo=$(dscacheutil -q host -a name "${host%.}" 2>/dev/null)
    v4=$(printf '%s\n' "$hinfo" | awk '/^ip_address/{print $2}')
    v6=$(printf '%s\n' "$hinfo" | awk '/^ipv6_address/{print $2}')
    ip=$(printf '%s\n' "$v4" | awk '$0 !~ /^(127\.|0\.)/{print; exit}')
    [ -n "$ip" ] || ip=$(printf '%s\n' "$v4" | head -1)
    [ -n "$ip" ] || ip=$(printf '%s\n' "$v6" | head -1)
  else
    host="(未响应)"; port="-"; ip="-"
  fi
  printf '%s|%s|%s|%s|%s|%s\n' "$host" "$ip" "${port:--}" "${svc}.${proto}" "$(svc_desc "${svc}.${proto}")" "$inst" >> "$TMP/data.tsv"
done < "$TMP/instances.u.tsv"

LC_ALL=C sort -t'|' -k1,1 -k4,4 "$TMP/data.tsv" > "$TMP/data.s.tsv"

# ---------- 输出 ----------
csv_q() { local s=$1; s=${s//\"/\"\"}; printf '"%s"' "$s"; }
md_q()  { printf '%s' "$1" | sed 's/|/\\|/g'; }

if [ "$BY_HOST" -eq 1 ]; then
  # 相邻同 host|ip 的行合并: host|ip|svc:port, svc:port, ...
  awk -F'|' '{ key=$1"|"$2
    if (key != prev) { if (prev != "") print prev"|"svc; prev=key; svc=$4":"$3 }
    else svc=svc", "$4":"$3 }
    END { if (prev != "") print prev"|"svc }' "$TMP/data.s.tsv" > "$TMP/byhost.tsv"
  case "$FORMAT" in
    csv)
      while IFS='|' read -r host ip svcs; do
        printf '%s,%s,%s\n' "$(csv_q "$host")" "$(csv_q "$ip")" "$(csv_q "$svcs")"
      done < "$TMP/byhost.tsv" ;;
    md)
      printf '| %s | %s | %s |\n|---|---|---|' "设备(主机名)" "IP" "广播的服务" 
      while IFS='|' read -r host ip svcs; do
        printf '\n| %s | %s | %s |' "$(md_q "$host")" "$(md_q "$ip")" "$(md_q "$svcs")"
      done < "$TMP/byhost.tsv"
      echo ;;
    *)
      printf '%-30s %-16s %s\n' "设备(主机名)" "IP" "广播的服务"
      while IFS='|' read -r host ip svcs; do
        printf '%-30s %-16s %s\n' "$host" "$ip" "$svcs"
      done < "$TMP/byhost.tsv" ;;
  esac
else
  case "$FORMAT" in
    csv)
      echo '"主机名","IP","端口","服务类型","服务说明","实例名"'
      while IFS='|' read -r host ip port svc desc inst; do
        printf '%s,%s,%s,%s,%s,%s\n' "$(csv_q "$host")" "$(csv_q "$ip")" "$(csv_q "$port")" "$(csv_q "$svc")" "$(csv_q "$desc")" "$(csv_q "$inst")"
      done < "$TMP/data.s.tsv" ;;
    md)
      printf '| %s | %s | %s | %s | %s | %s |\n|---|---|---|---|---|---|' "主机名" "IP" "端口" "服务类型" "服务说明" "实例名"
      while IFS='|' read -r host ip port svc desc inst; do
        printf '\n| %s | %s | %s | %s | %s | %s |' "$(md_q "$host")" "$(md_q "$ip")" "$(md_q "$port")" "$(md_q "$svc")" "$(md_q "$desc")" "$(md_q "$inst")"
      done < "$TMP/data.s.tsv"
      echo ;;
    *)
      printf '%-28s %-16s %-6s %-22s %-28s %s\n' "主机名" "IP" "端口" "服务类型" "服务说明" "实例名"
      while IFS='|' read -r host ip port svc desc inst; do
        printf '%-28s %-16s %-6s %-22s %-28s %s\n' "$host" "$ip" "$port" "$svc" "$desc" "$inst"
      done < "$TMP/data.s.tsv" ;;
  esac
fi
