"""
Reads queries from queries.csv and output to a json file
"""
import csv
import json
import argparse

# pylint: disable=C0103,C0301
if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--project", help="project folder in data/ directory")
    FLAGS, _ = parser.parse_known_args()

    ChromeDriverLocation = "/Users/raimibinkarim/Library/chromedriver"
    NoOfImages = str(150)
    QueryFilters = ""

    querylist = []
    header = "{\"Records\": ["
    tail = "] }"
    jsondump = header
    trailingsubheaderend = ",\"size\": \"medium\", " + \
        "\"print_urls\": false, \"output_directory\": \"data/" + FLAGS.project + \
        "\", " + "\"chromedriver\": \"" + ChromeDriverLocation + "\"}"

    with open('Queries') as csvfile:
        readcsv = csv.reader(csvfile, delimiter=',')
        for row in readcsv:
            leadingsubheader = "{ \"keywords\": \"" + \
                row[0] + " " + QueryFilters + "\","
            trailingsubheader = "\"limit\": " + NoOfImages + trailingsubheaderend
            jsondump = jsondump + leadingsubheader + trailingsubheader
            jsondump = jsondump + ","
    jsondump = jsondump[:-1] + tail

    with open('logs/scraper.json', 'w') as f:
        f.write(jsondump)
        f.close()
