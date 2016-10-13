#!/bin/bash

# Script that builds a deb package.

PROG=make-package.sh
fail() {
    EXIT_CODE=$1
    MESSAGE=$2
    echo "${PROG}: ${MESSAGE}" >&2
    exit $EXIT_CODE
}

./run-primitive-tests.sh > /dev/null || fail $? "primitive tests failed"

PROJECT_DIR="$(dirname $0)"
if [ "$PROJECT_DIR" == "." ] ; then
  PROJECT_DIR="$PWD"
elif [ "$PROJECT_DIR" == ".." ] ; then
  PROJECT_DIR=$(dirname "$PWD")
fi

OUTPUT="${PROJECT_DIR}/build"
PACKAGING_ROOT="${PROJECT_DIR}/packaging"
PACKAGING_SOURCE="${PACKAGING_ROOT}/source"
STAGE="${OUTPUT}/stage"
PKGNAME=virtualbox-auto
# echo "removing build directory ${OUTPUT}"
rm -rf "$OUTPUT" || exit $?
mkdir -p "$OUTPUT" || exit $?
cp -r "${PACKAGING_SOURCE}" "${STAGE}"  || exit $?

# Substitute variables into control files
CONTROL_FILE_DIR="${STAGE}/DEBIAN"
FILTERED_CONTROL_FILES="control prerm postrm postinst conffiles"
for VARIABLE in $(ls ${PACKAGING_ROOT}/variables/*) ; do
  REPLACEMENT=$(cat "${VARIABLE}")
  VARIABLE=$(basename $VARIABLE)
  echo "$VARIABLE" | grep -qv '|' || fail $? "variable name \"${VARIABLE}\" must not contain pipe character '|'"
  echo "$REPLACEMENT" | grep -qv '|' || fail $? "variable \"${VARIABLE}\" replacement \"${REPLACEMENT}\" must not contain pipe character '|'"
  for CONTROL_FILENAME in ${FILTERED_CONTROL_FILES} ; do
    CONTROL_FILE="${CONTROL_FILE_DIR}/${CONTROL_FILENAME}"
    PATTERN="s|@${VARIABLE}@|${REPLACEMENT}|g"
    # echo "using pattern $PATTERN on file ${CONTROL_FILE}"
    sed --in-place "$PATTERN" "${CONTROL_FILE}"
  done
done

USR_LIB_DIR="$STAGE/usr/lib/${PKGNAME}"
mkdir -p "$USR_LIB_DIR"
cp "$PROJECT_DIR/virtualbox_auto_start.py" \
   "$PROJECT_DIR/virtualbox_auto_stop.py" \
   "$PROJECT_DIR/virtualbox_auto_common.py" \
   "$USR_LIB_DIR" || exit $?

ETC_DIR="$STAGE/etc/${PKGNAME}"
mkdir -p "$ETC_DIR"
cp "$PROJECT_DIR/CONFIG.md" "${ETC_DIR}/README"

SYSTEMD_UNIT_FILES_DIR="$STAGE/lib/systemd/system"
mkdir -p "$SYSTEMD_UNIT_FILES_DIR"
cp "$PROJECT_DIR/${PKGNAME}.service" "$SYSTEMD_UNIT_FILES_DIR" || exit $?

DOC_DIR="$STAGE/usr/share/doc/${PKGNAME}"
mkdir -p "$DOC_DIR"
cp "$PROJECT_DIR/LICENSE" "${DOC_DIR}/copyright" || exit $?
find "$DOC_DIR" -type f -name "changelog*" -print0 | xargs -r -0 -n1 gzip -n --best
find "$DOC_DIR" -type f -print0 | xargs -r -0 chmod 0644
find "${STAGE}" -type d -print0 | xargs -r -0 chmod 0755

#find "$STAGE" -type f || exit $?
fakeroot dpkg-deb --build "${STAGE}" || exit $?
DEB="${STAGE}.deb"
if [ -f "$DEB" ] ; then
  CONTROL_FILE="${STAGE}/DEBIAN/control"
  VERSION=$(grep '^Version: ' "$CONTROL_FILE" | cut -d' ' -f2)
  ARCH=$(grep '^Architecture: ' "$CONTROL_FILE" | cut -d' ' -f2)
  mkdir -p "${OUTPUT}" || exit $?
  OUTFILE="${OUTPUT}/${PKGNAME}_${VERSION}_${ARCH}.deb"
  mv "$DEB" "${OUTFILE}" || exit $?
  echo "output: ${OUTFILE}"
  EXTRACT_DIR="${OUTPUT}/$(basename ${OUTFILE} .deb)"
  mkdir -p "${EXTRACT_DIR}"
  dpkg-deb --raw-extract "${OUTFILE}" "${EXTRACT_DIR}"
  find "${EXTRACT_DIR}" -type f | cut -c$(echo "${EXTRACT_DIR}/" | wc -c)-
  lintian "${OUTFILE}"
else
  echo "not found: $DEB" >&2
  exit 2
fi
