#!/usr/bin/awk -f
BEGIN { X="" }
$1~/[0-9]+/{ sub("[0-9]+",X" = \047&\047",$1); print $1;X=" ||" }
