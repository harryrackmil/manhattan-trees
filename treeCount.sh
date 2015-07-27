#!/bin/bash

cURL https://data.cityofnewyork.us/api/views/4eh7-xcm8/rows.csv?accessType=DOWNLOAD | grep -v ^1230\" | grep -v \"1230 | sed "s/a\ Circle,/a\ Circle/" | sed "s/\"//" > tmp.man
diff data/ManhattanTree.csv tmp.man > tmp.diff
if [ ! -e data/ManhattanTree.csv -o -s tmp.diff ]
	then
		rm -r data
		mkdir data
		mv tmp.man data/ManhattanTree.csv
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

		 
		grep '[0-9].*,' data/treesPerSt.csv | sed "s/st,/street,/" | grep 'street' | sed "s/[ a-z]//g" > data/stNum.csv

		grep '[0-9].*,' data/treesPerSt.csv | grep 'avenue' | sed "s/[ a-z]//g" > data/aveNum.csv
fi
rm tmp.* 

/usr/bin/Rscript treePlots.R



