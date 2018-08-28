"""
Reads queries from queries.csv and output to a json file
"""
import csv
import json

#pylint: disable=C0103,C0301
with open('config/download.json') as json_file:
    config = json.load(json_file)

ChromeDriverLocation = config['ChromeDriverLocation']
NoOfImages = str(config['NoOfImages'])
QueryFilters = config['QueryFilters']

querylist = []
header = "{\"Records\": ["
tail = "] }"
jsondump = header
trailingsubheaderend = ",\"size\": \"medium\", " + "\"print_urls\": false, \"output_directory\": \"data\", " + "\"chromedriver\": \"" + ChromeDriverLocation + "\"}"

with open('Queries') as csvfile:
    readcsv = csv.reader(csvfile, delimiter=',')
    for row in readcsv:
        leadingsubheader = "{ \"keywords\": \"" + row[0] + " " + QueryFilters + "\","
        trailingsubheader = "\"limit\": " + NoOfImages + trailingsubheaderend
        jsondump = jsondump + leadingsubheader + trailingsubheader
        jsondump = jsondump + ","
jsondump = jsondump[:-1] + tail

with open('logs/scraper.json', 'w') as f:
    f.write(jsondump)
    f.close()
