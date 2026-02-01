# Shell Scripting Notes (Linux)

## What Is a Shell Script?
A shell script is a text file of commands executed by the shell (Bash). Use scripts to automate tasks, manage systems, and glue tools together.

---

## 1. Basics
- Shebang: #!/usr/bin/env bash (portable) or #!/bin/bash.
- Make executable: chmod +x script.sh; run: ./script.sh.
- Comments: # This is a comment.
- Structure: header (shebang), variables, functions, main logic.

---

## 2. Variables & Special Variables
- Set: name="Alice" (no spaces around =); read: $name.
- Args: $0 (script name), $1, $2, ...
- Special:
  - $@: all args (each separately)
  - $*: all args (single string)
  - $# : number of args
  - $$ : PID of this script
  - $! : PID of last background job
  - $? : exit status of last command

---

## 3. Input / Output
- echo "Hello" (print), printf for formatted output.
- Read:
  - read var
  - read -p "Prompt: " var
  - read -s var (silent, e.g., passwords)
- Redirection:
  - > overwrite, >> append, < stdin, 2> stderr, &> stdout+stderr
- Here-doc:
  cat <<EOF
  multi-line
  text
  EOF
- Here-string: grep foo <<< "foo bar"

---

## 4. Environment Variables
- Set: export DB_USER=admin ; read: $DB_USER.
- Persist by adding to ~/.bashrc then source ~/.bashrc.
- List: env.

---

## 5. Arithmetic & Strings
- Arithmetic: sum=$((a + b)), modulo: $((n % 2)).
- Strings:
  - Length: ${#s}
  - Substring: ${s:pos:len}
  - Replace: ${s/old/new}
  - Concatenate: s="$s$extra"

---

## 6. Arrays & Associative Arrays
- Indexed: arr=(one two three) ; ${arr[0]} ; ${arr[@]}.
- Associative (Bash 4+):
  declare -A map
  map[region]=us-east-1
  for k in "${!map[@]}"; do echo "$k=${map[$k]}"; done

---

## 7. Conditionals
if [ "$x" -gt 10 ]; then
  echo "gt 10"
elif [ "$x" -eq 10 ]; then
  echo "eq 10"
else
  echo "lt 10"
fi
- Numeric: -eq -ne -gt -lt -ge -le
- Strings: = != -z -n (quote variables: "$var")
- File tests: -e -f -d -r -w -x (exists, file, dir, readable, writable, executable)

---

## 8. Loops
- For:
  for f in *.txt; do echo "File: $f"; done
- While:
  i=1; while [ $i -le 3 ]; do echo $i; i=$((i+1)); done
- Until:
  i=1; until [ $i -gt 3 ]; do echo $i; i=$((i+1)); done

---

## 9. Case (switch)
read -p "Enter a letter: " l
case $l in
  [a-z]) echo "lower" ;;
  [A-Z]) echo "upper" ;;
  [0-9]) echo "digit" ;;
  *) echo "other" ;;
esac

---

## 10. Functions
log() { echo "[INFO] $*"; }
error() { echo "[ERROR] $*" >&2; }
- Return numeric: return 0; pass values via output: echo value and capture with $(func).

---

## 11. File Operations & Tests
- Permissions/ownership: chmod, chown, chgrp.
- Common tests:
  [ -f myfile.txt ] && echo "regular file"
  [ -d /var/log ] && echo "directory exists"

---

## 12. Permissions Deep Dive
- Bits: read=4, write=2, execute=1.
- Numeric: owner/group/others → 755 (rwxr-xr-x), 644 (rw-r--r--).
- Symbolic: chmod u+x script.sh, chmod g-w file, chmod o-r file.
- Ownership: sudo chown user:group file, sudo chgrp group file.
- Examples:
  chmod 755 *.sh
  chmod 640 /var/log/*.log
  sudo chown root:adm /var/log/*.log

---

## 13. Useful Commands
- Files: ls, cat, cp, mv, rm.
- Text: grep, sed, awk, sort, uniq, wc.
- Download: wget, curl.
- Processes: ps, top (interactive), htop.
- Ports: ss -tuln, lsof -nP -iTCP -sTCP:LISTEN.
- Disk/memory: df -h, du -sh /path, free -h.
- Examples:
  ps aux --sort=-%cpu | head
  find . -name '*.sh'
  sed -i 's/old/new/g' file.txt
  awk '{print $1, $NF}' file.txt

---

## 14. CPU & Resource Monitoring (Linux)
- CPU-heavy processes: ps aux --sort=-%cpu | head -10.
- Live view: top, htop.
- Memory: free -h; system: vmstat 2 5.
- Per-core CPU (sysstat): mpstat -P ALL 1 5.
- Disk I/O (sysstat): iostat -xz 1 3.
- Disk space: df -h; directory sizes: du -sh /var/log/*.
- Load: uptime.
- Script:
  #!/usr/bin/env bash
  echo "=== $(date) ==="
  echo "Top CPU:"; ps aux --sort=-%cpu | head -6
  echo; echo "Memory:"; free -h
  echo; echo "Disk space:"; df -h | head -10

---

## 15. Networking Diagnostics (Linux)
- Ping: ping -c 4 google.com.
- Path: traceroute google.com.
- DNS: dig example.com +short or nslookup example.com.
- HTTP: curl -I https://example.com.
- Port check: nc -vz example.com 443 (or nc -vz localhost 22).
- Quick checker:
  #!/usr/bin/env bash
  host=${1:-google.com}
  ping -c 2 "$host" || echo "Ping failed"
  traceroute "$host" | head -15
  dig +short "$host" | head -5

---

## 16. Background Jobs
- Run in background: sleep 10 &; capture PID: $!.
- Example:
  sleep 5 & pid=$!
  wait "$pid"; echo "Exit status: $?"

---

## 17. Error Handling & Debugging
- Exit status: $? (0 = success).
- Safer scripts: set -euo pipefail.
- Trace: set -x; unset vars error: set -u.

---

## 18. Traps & Signals
trap 'echo "Interrupted"; exit 130' INT
trap 'echo "Cleaning up"' EXIT

---

## 19. Best Practices & Security
- Always quote variables: "$var".
- Validate inputs; fail fast on errors.
- Use functions for reusable logic.
- Avoid eval; beware command injection.

---

## 20. Install Tools (Linux)
- Debian/Ubuntu:
  ```bash
  sudo apt update
  sudo apt install -y sysstat htop lsof traceroute netcat-openbsd iproute2
  ```
- RHEL/CentOS/Amazon Linux:
  ```bash
  sudo yum install -y sysstat htop lsof traceroute nmap-ncat iproute
  ```
- Fedora/Rocky/AlmaLinux:
  ```bash
  sudo dnf install -y sysstat htop lsof traceroute nmap-ncat iproute
  ```
- Enable `sysstat` data collection (for `sar` history; `mpstat`/`iostat` work without it):
  ```bash
  sudo systemctl enable --now sysstat || true
  ```

### Try It: Examples (Linux tools)
- `mpstat` (per-core CPU):
  ```bash
  mpstat -P ALL 1 5
  # Watch %usr, %sys, %iowait, %idle per core
  ```
- `iostat` (disk I/O):
  ```bash
  iostat -xz 1 3
  # Focus on %util (busy time), await (avg wait), r/s, w/s
  ```
- `sar` (historical/live stats):
  ```bash
  sar -q 1 3          # load/queue
  sar -n DEV 1 3      # network per interface
  sar -r 1 3          # memory
  ```
- `ss` (sockets/ports):
  ```bash
  ss -tuln            # listening TCP/UDP ports
  ss -s               # summary of sockets
  ss -t state established '( dport = :22 or sport = :22 )'  # SSH flows
  ```
- `lsof` (open files/sockets):
  ```bash
  lsof -nP -iTCP -sTCP:LISTEN   # services listening on TCP
  lsof /var/log/syslog          # processes using this file (Debian-based)
  ```
- `traceroute` (path to host):
  ```bash
  traceroute -n example.com     # numeric output; * means timeout at a hop
  ```
- `nc` / `ncat` (check ports and simple servers):
  ```bash
  nc -vz localhost 22           # test if SSH port is reachable
  nc -l -p 8080                 # start a simple TCP listener on 8080
  # In another terminal: printf 'hello\n' | nc 127.0.0.1 8080
  ```
- `htop` (interactive):
  ```bash
  htop
  # Sort by CPU (F6), show process tree (F5), filter (/) and kill (F9)
  ```

---

## 21. Command Substitution
- Prefer $(cmd) to backticks for nesting and readability.

---

## 22. Quick-Reference Cheatsheet
- Date: date '+%Y-%m-%d %H:%M:%S'
- IO redirection: cmd > out, cmd >> out, cmd 2> err, cmd &> all
- Pipelines: ps aux | grep bash | wc -l
- Find/Grep: find . -name '*.sh', grep -R ERROR /var/log
- Edit/Parse: sed 's/old/new/g' file, awk '{print $1, $NF}' file
- Permissions: chmod 644 file, chmod u+x script.sh, sudo chown user:group file
- Processes: ps aux --sort=-%cpu | head, top, htop
- Ports: ss -tuln, lsof -nP -iTCP -sTCP:LISTEN
- Disk/Mem: df -h, du -sh /path, free -h

---

## 23. Example Scripts
- Greet user:
  #!/usr/bin/env bash
  read -p "Name: " name
  echo "Hello, $name!"
- Backup directory:
  #!/usr/bin/env bash
  src="$1"; dst="$2"
  [ -z "$src" ] || [ -z "$dst" ] && { echo "Usage: $0 SRC DST"; exit 1; }
  mkdir -p "$dst"
  cp -a "$src"/* "$dst"/
  echo "Backup complete"
- Menu:
  #!/usr/bin/env bash
  while true; do
    echo "1) date"; echo "2) ls -l"; echo "3) exit"
    read -p "Choose: " c
    case $c in
      1) date;; 2) ls -l;; 3) break;; *) echo "Invalid";;
    esac
  done
- Even/Odd:
  #!/usr/bin/env bash
  n=${1:?Usage: $0 NUMBER}
  if [ $((n % 2)) -eq 0 ]; then echo "even"; else echo "odd"; fi
- Masked password:
  #!/usr/bin/env bash
  read -s -p "Password: " pw; echo; echo "Received"
- Find/Replace:
  #!/usr/bin/env bash
  file=${1:?file}; from=${2:?from}; to=${3:?to}
  sed -i "s/${from}/${to}/g" "$file"
- Open ports:
  #!/usr/bin/env bash
  ss -tuln
- Uptime/Load:
  #!/usr/bin/env bash
  uptime

---

## 24. Practice Exercises
- Variables & input: prompt for name/age; print greeting with date.
- Background: run sleep in background, capture $!, wait, show $?.
- Conditionals: check file exists, readable, and lines (wc -l) > 100.
- Loops: iterate *.log and compress any over 10MB.
- Functions: implement log(), error(), die() helpers.
- Monitoring: print top CPU, memory, disk, and open ports.
- Networking: test a list of hosts/ports using nc and curl -I.

---

## 25. Resources
- man bash
- The Linux Documentation Project (TLDP)
- ShellCheck: https://www.shellcheck.net/
- Bash Hackers Wiki: https://wiki.bash-hackers.org/

---

Practice by writing and running your own scripts. Start small; iterate quickly; keep your scripts safe and readable.
