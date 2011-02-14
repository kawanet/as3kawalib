#!/bin/sh

cd `dirname $0`

die () {
    echo "$*" >&2
    exit 1
}

ASDOC=`which asdoc`

[ -f "$ASDOC" ] || ASDOC=`ls -t \
/Applications/FDT*/plugins/com.powerflasher.fdt.shippedflex_*/flex/bin/asdoc \
/Applications/Adobe\ Flash\ Builder*/sdks/*/asdoc \
/Applications/Adobe\ Flash\ Builder*/sdks/*/bin/asdoc \
/opt/flex_sdk_*/bin/asdoc \
2> /dev/null | head -1`

[ -f "$ASDOC" ] || die "asdoc not found"

LC_ALL=C $ASDOC -source-path ../src -doc-sources ../src/net/kawa/*/*.as -output ../docs

for f in `find ../docs -name '*.html'`; do \
  sed 's#</footer><br/>.*, .*</center></div>#</footer><br/>\&copy; 2011 Yusuke Kawasaki. All rights reserved.</center></div>#; s#<!--<br/>.*, .*-->##' < $f > $f~ && mv $f~ $f; \
done

ls -l ../docs/index.html
