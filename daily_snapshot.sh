#!/usr/bin/env bash
set -euo pipefail

# Daily system snapshot for Linux: writes a timestamped report of key metrics.
# Usage: ./daily_snapshot.sh [OUTPUT_DIR]

OUTDIR="${1:-snapshots}"
HOSTNAME="$(hostname -f 2>/dev/null || hostname)"
TS="$(date '+%Y-%m-%d_%H-%M-%S')"
mkdir -p "$OUTDIR"
OUTFILE="$OUTDIR/snapshot_${HOSTNAME}_${TS}.txt"

has() { command -v "$1" >/dev/null 2>&1; }

print_section() {
  echo "=== $1 ===" >>"$OUTFILE"
}

run_cmd() {
  local title="$1"; shift
  print_section "$title"
  if "$@" >>"$OUTFILE" 2>&1; then
    :
  else
    echo "[WARN] Command failed: $*" >>"$OUTFILE"
  fi
  echo >>"$OUTFILE"
}

echo "# Snapshot for $HOSTNAME at $(date '+%Y-%m-%d %H:%M:%S %Z')" >"$OUTFILE"
echo >>"$OUTFILE"

# Core basics
has uptime && run_cmd "Uptime" uptime || echo "=== Uptime ===\n[SKIP] uptime not found\n" >>"$OUTFILE"
run_cmd "Date" date '+%Y-%m-%d %H:%M:%S %Z'
run_cmd "Top CPU (ps)" bash -c 'ps aux --sort=-%cpu | head -10'

# Memory and disk
if has free; then
  run_cmd "Memory (free)" free -h
else
  echo -e "=== Memory (free) ===\n[SKIP] free not found\n" >>"$OUTFILE"
fi
run_cmd "Disk space (df)" df -h

# CPU per-core and disk IO (sysstat)
if has mpstat; then
  run_cmd "CPU per-core (mpstat)" mpstat -P ALL 1 5
else
  echo -e "=== CPU per-core (mpstat) ===\n[SKIP] mpstat not found (install sysstat)\n" >>"$OUTFILE"
fi
if has iostat; then
  run_cmd "Disk I/O (iostat)" iostat -xz 1 3
else
  echo -e "=== Disk I/O (iostat) ===\n[SKIP] iostat not found (install sysstat)\n" >>"$OUTFILE"
fi

# Load average (/proc)
if [ -r /proc/loadavg ]; then
  run_cmd "Load average (/proc/loadavg)" cat /proc/loadavg
else
  echo -e "=== Load average (/proc/loadavg) ===\n[SKIP] /proc/loadavg unavailable\n" >>"$OUTFILE"
fi

# Networking: sockets, listeners, connectivity, path
if has ss; then
  run_cmd "Sockets/Ports (ss)" ss -tuln
  run_cmd "Socket Summary (ss)" ss -s
else
  echo -e "=== Sockets/Ports (ss) ===\n[SKIP] ss not found (install iproute2/iproute)\n" >>"$OUTFILE"
fi
if has lsof; then
  run_cmd "Listening TCP (lsof)" lsof -nP -iTCP -sTCP:LISTEN
else
  echo -e "=== Listening TCP (lsof) ===\n[SKIP] lsof not found\n" >>"$OUTFILE"
fi
if has ping; then
  run_cmd "Ping google.com" ping -c 2 google.com
fi
if has traceroute; then
  run_cmd "Traceroute google.com" bash -c 'traceroute -n google.com | head -20'
else
  echo -e "=== Traceroute google.com ===\n[SKIP] traceroute not found\n" >>"$OUTFILE"
fi

echo "Snapshot written to: $OUTFILE"
