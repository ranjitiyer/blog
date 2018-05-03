#!/bin/bash

# FS - Field separator
# OFS - Output field separator
# RS - Record separator
# ORS - Output record separator
# FILENAME - The filename
# NF - Number of fields
# NR - Number of Records

# Print the file
awk '{print}' < 1000-cities.txt

# Print all cities
awk '{FS=","} {print $2}' < 1000-cities.txt

# Print number of cities grouped by state
cat 1000-cities.txt | awk '{FS=","} {print $3}' | sort | uniq -c | sort -k 2n

# Print all cities in Florida
awk '/Florida/ {print}' < 1000-cities.txt

# Total population in the top 1000 cities
awk 'BEGIN {FS=","; total=0} {total+=$4} END {print "Total population in 1000 top cities " total} ' < 1000-cities.txt

# Total population in the CA cities
awk 'BEGIN {FS=","; total=0} /California/ {total+=$4} END {print "Total population in top CA cities " total} ' < 1000-cities.txt

# Total population per state of the top 1000 cities
cat 1000-cities.txt | awk 'BEGIN {FS=","; OFS="|"} {cities[$3]+=$4} END {for (i in cities) {print i,cities[i]}}' | sort -t\| -k 2n

# Bucketize city populations
awk 'BEGIN {FS=","; OFS="|"; _1m=0; _500k=0; _250k=0; _100k=0; _50k=0; _25k=0} \
	 {	if ($4 > 1000000) { _1m++ } \
		else if ($4 > 500000) { _500k++ } \
		else if ($4 > 250000) { _250k++ } \
		else if ($4 > 100000) { _100k++ } \
		else if ($4 > 50000) { _50k++ } \
		else if ($4 > 25000) { _25k++ } \
	} END { \
	 print " 1m: " _1m; \
	 print " 500k: " _500k; \
	 print " 250k: " _250k; \
	 print " 100k: " _100k; \
	 print " 50k: " _50k; \
	 print " 20k: " _25k; \
	 }' < 1000-cities.txt

