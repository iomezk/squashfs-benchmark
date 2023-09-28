#!/bin/sh
set -e

SNAP_NAME=firefox
SNAP_ID=3wdHCAVyZEmYsCMFDE9qt92UV8rC8Wdk
REV1=3131
REV2=3166
COMP=zstd LVL=22

mksfs() {
  # SOURCE_DATE_EPOCH=946684800
  [ -e "${SNAP_ID}_${REV}.${COMP}.snap" ] || mksquashfs \
   "/snap/${SNAP_NAME}/${REV}/" "${SNAP_NAME}_${REV}.${COMP}.snap" -quiet \
   -noappend -no-fragments -no-progress -all-root -no-xattrs "$@"
  ln -sf "${SNAP_NAME}_${REV}.${COMP}.snap" "${SNAP_ID}_${REV}.snap"
}
set --
case "$COMP" in
  no) set -- "$@" -comp xz -noI -noD ;;
  *)  set -- "$@" -comp "$COMP"
esac
case "$LVL" in
  [0-9]*) set -- "$@" -Xcompression-level "$LVL"
esac
REV="$REV1" mksfs "$@"
REV="$REV2" mksfs "$@"

# no -A, as snapcraft.io does
xdelta3 -e -f -s "${SNAP_ID}_${REV1}.snap" "${SNAP_ID}_${REV2}.snap" \
 "${SNAP_NAME}_${REV2}.snap.xdelta3-${REV1}-to-${REV2}-${COMP}"
