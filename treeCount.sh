#!/bin/bash

rm -r data
mkdir data
cURL https://data.cityofnewyork.us/api/views/4eh7-xcm8/rows.csv?accessType=DOWNLOAD | grep -v ^1230\" | grep -v \"1230 | sed "s/a\ Circle,/a\ Circle/" | sed "s/\"//" > data/ManhattanTree.csv

hdfs dfs -rmr data/trees
hdfs dfs -mkdir data/trees
hdfs dfs -copyFromLocal data/ManhattanTree.csv data/trees/tree.csv

hdfs dfs -rmr output
hdfs dfs -mkdir output
gradle clean jar
hadoop jar ./build/libs/trees.jar data/trees/tree.csv output/specSt output/st output/spec

hdfs dfs -copyToLocal output/specSt/part-00000 data/treesPerStSp.csv
hdfs dfs -copyToLocal output/st/part-00000 data/treesPerSt.csv
hdfs dfs -copyToLocal output/spec/part-00000 data/treesPerSp.csv

 
grep '[0-9].*,' data/treesPerSt.csv | sed "s/st,/street,/" | grep 'street' | sed "s/[ a-z]//g" > data/cleanSt.csv

r
cleanSt = read.csv("data/cleanSt.csv", header = FALSE)
names(cleanSt) = c("street", "count")
aggSt = aggregate(cleanSt, by = list(cleanSt$street), FUN = sum)
plot(aggSt$Group.1, aggSt$count, type = 'l')
axis(1, , at = seq(10,220, by = 10))

