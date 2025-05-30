set terminal png size 1024,768
set size 1,1
set key right top
set grid y

set title "Apache Benchmark - Endpoint [ /post ]" font 'Noto Sans Mono:style=Bold,14'
set xlabel "Request" font 'Noto Sans Mono:style=Regular,10'
set ylabel "Response Time (ms)" font 'Noto Sans Mono:style=Regular,10'

set output "chart.png"

## Multiple metrics
plot "gplot.1000.data" using 10 smooth sbezier with lines title "Requests [ 1000 ] - Concurrency [ 100 ]", \
     "gplot.2000.data" using 10 smooth sbezier with lines title "Requests [ 2000 ] - Concurrency [ 200 ]", \
     "gplot.3000.data" using 10 smooth sbezier with lines title "Requests [ 3000 ] - Concurrency [ 300 ]", \
     "gplot.5000.data" using 10 smooth sbezier with lines title "Requests [ 5000 ] - Concurrency [ 500 ]"

exit
