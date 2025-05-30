#!/bin/sh

set -e

ab -k -f ALL -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept: */*' -s 30 -n 1000 -c 100 -g gplot.1000.data http://localhost/

gnuplot ./config/gplot.p
