#!/bin/sh
set -e

THREADS=${1:-single}
PASSES=${2:-1}
TESTSNAP=/snap/firefox/current/
TMPDIR=/tmp/squashfs-benchmark

die() { echo "Error${1:+: }${1-}" >&2; exit 1; }
[ "$(id -u)" = 0 ] || die "This script should be run as root"
[ -e "$TESTSNAP" ] || die "Test snap is not installed"
mkdir -p "$TMPDIR/mnt"

COMP_LIST="xz -
lzo -
"
[ "x$PASSES" = x1 ] && COMP_LIST="$COMP_LIST$COMP_LIST$COMP_LIST"
COMP_LIST="$COMP_LIST$(seq -f 'zstd %g' 1 22)
"

{
cd "$TMPDIR"
for i in $(seq 1 "$PASSES"); do
	printf %s "$COMP_LIST" | shuf | while read -r COMP LVL; do
		if [ "x$LVL" = x- ]; then
			set --
		else
			set -- -Xcompression-level "$LVL"
		fi
		mksquashfs "$TESTSNAP" test.sfs -quiet -noappend -comp "$COMP" \
			-no-fragments -no-progress -all-root -no-xattrs "$@"
		SIZE=$(wc -c <test.sfs)
		mount -t squashfs -o "ro,nodev,relatime,errors=continue,threads=$THREADS,x-gdu.hide" test.sfs mnt
		echo 3 >/proc/sys/vm/drop_caches
		sleep 1m
		TIME=$(date +%s%3N)
		tar -c mnt >/dev/zero
		TIME=$(( $(date +%s%3N) - $TIME ))
		umount mnt
		rm test.sfs
		printf '%s\n' "$COMP,$LVL,$SIZE,$TIME"
	done
done
} >"results-$THREADS.csv"
