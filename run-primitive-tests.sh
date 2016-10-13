#!/bin/bash

CONF_DIR=$(mktemp -d "${PWD}/test_virtualbox-auto_XXXXXX")

echo '{"user": "harry"}' > "$CONF_DIR/potter.auto"
echo '{"user": "hermione", "stop_action": "poweroff"}' > "$CONF_DIR/granger.auto"

NUM_TESTS=0

./virtualbox_auto_start.py --conf-dir "$CONF_DIR" --dry-run=succeed --verbose
START_SUCCEED_EXIT=$?
NUM_TESTS=$((NUM_TESTS + 1))

./virtualbox_auto_stop.py --conf-dir "$CONF_DIR" --dry-run=succeed --verbose
STOP_SUCCEED_EXIT=$?
NUM_TESTS=$((NUM_TESTS + 1))

rm -rf "$CONF_DIR"

NUM_FAILED=0

if [ $START_SUCCEED_EXIT -ne 0 ] ; then
  echo "start 'success' test failed with code $START_SUCCEED_EXIT" >&2
  NUM_FAILED=$((NUM_FAILED + 1))
fi

if [ $STOP_SUCCEED_EXIT -ne 0 ] ; then
  echo "stop 'success' test failed with code $STOP_SUCCEED_EXIT" >&2
  NUM_FAILED=$((NUM_FAILED + 1))
fi

echo 
echo "--------------------------------------------"
echo "$NUM_FAILED failures out of $NUM_TESTS tests"

exit $NUM_FAILED
