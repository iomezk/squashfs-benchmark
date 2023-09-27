#!/bin/sh

SNAP_ID=3wdHCAVyZEmYsCMFDE9qt92UV8rC8Wdk
REV1=3131
REV2=3166
COMP=zstd

ln -sf "${SNAP_ID}_${REV1}.${COMP}.snap" "${SNAP_ID}_${REV1}.snap"
ln -sf "${SNAP_ID}_${REV2}.${COMP}.snap" "${SNAP_ID}_${REV2}.snap"

# no -A, as snapcraft.io does
xdelta3 -e -f -s "${SNAP_ID}_${REV1}.snap" "${SNAP_ID}_${REV2}.snap" "firefox_${REV2}.snap.xdelta3-${REV1}-to-${REV2}-${COMP}"
