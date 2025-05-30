#!/bin/sh

set -e

ab -k -f ALL -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept: */*' -s 30 -p ./config/payload.json -n 1000 -c 100 -g gplot.1000.data http://localhost/post
ab -k -f ALL -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept: */*' -s 30 -p ./config/payload.json -n 2000 -c 200 -g gplot.2000.data http://localhost/post
ab -k -f ALL -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept: */*' -s 30 -p ./config/payload.json -n 3000 -c 300 -g gplot.3000.data http://localhost/post
ab -k -f ALL -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept: */*' -s 30 -p ./config/payload.json -n 5000 -c 500 -g gplot.5000.data http://localhost/post

gnuplot ./config/gplot.p
