#!/bin/sh

# In 'translator' mode files will contain empty translated texts
# where translation is not available, we'll remove these later

tx --debug pull -a --mode translator

PWD=`dirname "$0"`

do_clean()
{
    # do not cleanup en_US files
    echo "$1" | grep -v en_US > /dev/null || return

    echo "Cleaning $1"

    # remove untranslated/empty texts
    perl -pi -e "s/^\\\$labels\[[^]]+\]\s+=\s+'';\n//" $1
    perl -pi -e "s/^\\\$messages\[[^]]+\]\s+=\s+'';\n//" $1
    # remove variable initialization
    perl -pi -e "s/^\\\$(labels|messages)\s*=\s*array\(\);\n//" $1
    # remove (one-line) comments
    perl -pi -e "s/^\\/\\/.*//" $1
    # remove empty lines (but not in file header)
    perl -ne 'print if ($. < 18 || length($_) > 1)' $1 > $1.tmp
    mv $1.tmp $1
}

# clean up translation files
for file in $PWD/../program/localization/*/*.inc; do
    do_clean $file
done
for file in $PWD/../plugins/*/localization/*.inc; do
    do_clean $file
done
