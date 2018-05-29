We are using csv data about the top 1000 US cities with the largest population recorded in 2013 for some simple data exploration and analysis using AWK.

1. The simplest command in awk is to print the file

```bash
=> awk '{print}' < 1000-cities.txt | more

1,New York,New York,8405837,4.8%
2,Los Angeles,California,3884307,4.8%
3,Chicago,Illinois,2718782,-6.1%
4,Houston,Texas,2195914,11.0%
5,Philadelphia,Pennsylvania,1553165,2.6%
6,Phoenix,Arizona,1513367,14.0%
7,San Antonio,Texas,1409019,21.0%
. . .

```

2. AWK assumes a tabular data model and takes in overrides for field separator. While each line is read, individual columns are accessible through internal variables. For example $1 refers to data in the first column of the current line and on so. In this example, we use the fact that city names appears in column 2 of the csv file and print it.

```bash
=> awk '{FS=","} {print $2}' < 1000-cities.txt | more
York,New
Los Angeles
Chicago
Houston
Philadelphia
Phoenix
San Antonio
San Diego
```

3. We can then group the top 1000 cities by state and get a sense of which states have more populous cities. Here use print the state name which is in column 3, hence $3

```bash
=> cat 1000-cities.txt | awk '{FS=","} {print $3}' | sort | uniq -c | sort -k 2n
   . . .
   . . .
  15 Connecticut
  16 Missouri
  16 New York
  17 Tennessee
  17 Virginia
  18 Georgia
  19 Utah
  20 Wisconsin
  21 Colorado
  21 Indiana
  22 New Jersey
  22 North Carolina
  24 Minnesota
  25 Arizona
  28 Washington
  31 Michigan
  33 Ohio
  36 Massachusetts
  52 Illinois
  73 Florida
  83 Texas
 212 California
```
Unsurprisingly California being the largest state geographically and overall population has the most cities in the top 1000 most populous cities. 

4. We then use AWK's regular expression support to filter some data and print only top cities in Florida

```bash
=> awk '/Florida/ {print}' < 1000-cities.txt
13,Jacksonville,Florida,842583,14.3%
44,Miami,Florida,417650,14.9%
53,Tampa,Florida,352957,16.0%
77,Orlando,Florida,255483,31.2%
78,St. Petersburg,Florida,249688,0.3%
89,Hialeah,Florida,233394,3.2%
125,Tallahassee,Florida,186411,21.8%
139,Fort Lauderdale,Florida,172389,0.7%
142,Port St. Lucie,Florida,171016,91.7%
146,Cape Coral,Florida,165831,60.4%
150,Pembroke Pines,Florida,162329,17.4%
174,Hollywood,Florida,146526,4.8%
196,Miramar,Florida,130288,74.7%
204,Gainesville,Florida,127488,12.8%
208,Coral Springs,Florida,126604,5.7%
243,Miami Gardens,Florida,111378,10.5%
252,Clearwater,Florida,109703,0.1%
270,Palm Bay,Florida,104898,31.7%
276,Pompano Beach,Florida,104410,4.0%
```

5. AWK supports math operations and C-like syntax that we can use for calculating the total US population in the top 1000 cities. Variable initialization is optional but shown here in case the default value must be non-zero

```bash
=> awk 'BEGIN {FS=","; total=0} {total+=$4} END {print "Total population in 1000 top cities " total} ' < 1000-cities.txt
Total population in 1000 top cities 131132443
```

6. If we wanted to know the total population of all cities in California we would need a filter to limit our analysis to cities in Calfornia and then do a sum over populations in CA.

```bash
=> awk 'BEGIN {FS=","; total=0} /California/ {total+=$4} END {print "Total population in top CA cities " total} ' < 1000-cities.txt
Total population in top CA cities 27910620
```

7. We can also calculate total population grouped by state by using AWK's support for associative arrays. `OFS` is a builtin AWK variable to set a separator when printing multiple values in the output

```bash
# Total population per state of the top 1000 cities
cat 1000-cities.txt | awk 'BEGIN {FS=","; OFS="|"} {cities[$3]+=$4} END {for (i in cities) {print i,cities[i]}}' | sort -t\| -k 2n

=> cat 1000-cities.txt | awk 'BEGIN {FS=","; OFS="|"} {cities[$3]+=$4} END {for (i in cities) {print i,cities[i]}}' | sort -t\| -k 2n
Vermont|42284
Maine|66318
West Virginia|99998
Delaware|108891
Wyoming|122076
South Dakota|235488
New Hampshire|239934
Montana|277392
North Dakota|281945
Alaska|300950
Hawaii|347884
Mississippi|427944
Rhode Island|499878
Idaho|638333
District of Columbia|646449
Arkansas|787011
Nebraska|807304
South Carolina|812734
New Mexico|953296
Maryland|954852
Iowa|1037690
Kentucky|1079181
Louisiana|1238263
Connecticut|1239817
Alabama|1279813
Kansas|1327215
Utah|1440569
Nevada|1481832
Oklahoma|1666530
Oregon|1680656
Missouri|1843953
New Jersey|1859793
Wisconsin|1910367
Georgia|1995615
Minnesota|2055749
Virginia|2236964
Indiana|2393472
Tennessee|2483464
Pennsylvania|2598080
Washington|2956938
Michigan|2979267
Massachusetts|3007084
Colorado|3012284
North Carolina|3358746
Ohio|3480839
Arizona|4691466
Illinois|6055539
Florida|7410114
New York|9933332
Texas|14836230
California|27910620
```

8. As the last example, we can classify populations in ranges.

```bash
# Bucketize city populations

=> awk 'BEGIN {FS=","; OFS="|"; _1m=0; _500k=0; _250k=0; _100k=0; _50k=0; _25k=0} \
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
   
 1m: 9
 500k: 25
 250k: 43
 100k: 216
 50k: 450
 20k: 257   
```

This tells us there are 9 cities with a population greater than 1 million, 27 cities with a population between 500k and a million and 257 cities with a population between 20k and 50k.
