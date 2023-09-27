#!/bin/sh
set -e

SNAP_NAME=firefox
SNAP_ID=3wdHCAVyZEmYsCMFDE9qt92UV8rC8Wdk
REV1=3131
REV2=3166
COMP=zstd
LVL=22

mksfs() {
  # SOURCE_DATE_EPOCH=946684800
  [ -e "${SNAP_ID}_${REV}.${COMP}.snap" ] || mksquashfs \
   "/snap/${SNAP_NAME}/${REV}/" "${SNAP_ID}_${REV}.${COMP}.snap" -quiet \
   -noappend -comp "$COMP" -no-fragments -no-progress -all-root -no-xattrs "$@"
  ln -sf "${SNAP_ID}_${REV}.${COMP}.snap" "${SNAP_ID}_${REV}.snap"
}
if [ "x$LVL" = x- ]; then
  set --
else
  set -- -Xcompression-level "$LVL"
fi
REV="$REV1" mksfs "$@"
REV="$REV2" mksfs "$@"

# no -A, as snapcraft.io does
xdelta3 -e -f -s "${SNAP_ID}_${REV1}.snap" "${SNAP_ID}_${REV2}.snap" \
 "${SNAP_NAME}_${REV2}.snap.xdelta3-${REV1}-to-${REV2}-${COMP}"
