#!/bin/bash

OUTPUT=$PWD/build

STAGE="${OUTPUT}/stage"

echo "removing build directory ${OUTPUT}"
rm -rf "$OUTPUT" || exit $?
mkdir -p "$OUTPUT"
cp -r "$PWD/packaging" "${STAGE}"  || exit $?

USR_LIB_DIR="$STAGE/usr/lib/virtualbox-auto"
mkdir -p "$USR_LIB_DIR"
cp "$PWD/virtualbox_auto_start.py" \
   "$PWD/virtualbox_auto_stop.py" \
   "$PWD/virtualbox_auto_common.py" \
   "$USR_LIB_DIR" || exit $?

ETC_DIR="$STAGE/etc/virtualbox-auto"
mkdir -p "$ETC_DIR"
cp "$PWD/README.md" "${ETC_DIR}/README"

SYSTEMD_UNIT_FILES_DIR="$STAGE/lib/systemd/system"
mkdir -p "$SYSTEMD_UNIT_FILES_DIR"
cp "$PWD/virtualbox-auto.service" "$SYSTEMD_UNIT_FILES_DIR" || exit $?

DOC_DIR="$STAGE/usr/share/doc/virtualbox-auto"
mkdir -p "$DOC_DIR"
cp "$PWD/LICENSE" "${DOC_DIR}/copyright" || exit $?
find "$DOC_DIR" -type f -name "changelog*" -print0 | xargs -r -0 -n1 gzip -n --best
find "$DOC_DIR" -type f -print0 | xargs -r -0 chmod 0644
find "${STAGE}" -type d -print0 | xargs -r -0 chmod 0755

#find "$STAGE" -type f || exit $?
fakeroot dpkg-deb --build "${STAGE}" || exit $?
DEB="${STAGE}.deb"
if [ -f "$DEB" ] ; then
  CONTROL_FILE="$PWD/packaging/DEBIAN/control"
  VERSION=$(grep '^Version: ' "$CONTROL_FILE" | cut -d' ' -f2)
  ARCH=$(grep '^Architecture: ' "$CONTROL_FILE" | cut -d' ' -f2)
  mkdir -p "${OUTPUT}" || exit $?
  OUTFILE="${OUTPUT}/virtualbox-auto_${VERSION}_${ARCH}.deb"
  mv "$DEB" "${OUTFILE}" || exit $?
  echo "output: ${OUTFILE}"
  lintian "${OUTFILE}"
else
  echo "not found: $DEB" >&2
  exit 2
fi
