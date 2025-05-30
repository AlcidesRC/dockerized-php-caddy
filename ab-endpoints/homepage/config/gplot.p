set terminal png size 1024,768
set size 1,1
set key right top
set grid y

set title "Apache Benchmark - Endpoint [ / ]" font 'Noto Sans Mono:style=Bold,14'
set xlabel "Request" font 'Noto Sans Mono:style=Regular,10'
set ylabel "Response Time (ms)" font 'Noto Sans Mono:style=Regular,10'

set output "chart.png"

## Single metric
plot "gplot.1000.data" using 10 smooth sbezier with lines title "Requests [ 1000 ] - Concurrency [ 100 ]"

exit
