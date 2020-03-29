"""
Rename, remove files
"""
import os
import json
import magic
from tqdm import tqdm
import argparse

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--project", help="project folder in data/ directory")
    FLAGS, _ = parser.parse_known_args()

    with open('download_images/download.json') as json_file:
        config = json.load(json_file)
    QueryFilters = config['QueryFilters']

    # Rename folders in data
    base = os.getcwd() + "/data/" + FLAGS.project + "/"
    for f in os.listdir("./data/" + FLAGS.project):
        if f == ".DS_Store":
            continue
        if not QueryFilters.strip() == "":
            os.rename(os.path.join(base, f), os.path.join(base, f.split(QueryFilters)[0]).replace(" ",""))

    # Rename files and remove if necessary
    for folder in os.listdir("./data/" + FLAGS.project + "/"):
        basefolder = os.path.join(base, folder)
        if folder == ".DS_Store":
            continue
        print("     " + folder)
        for filename in tqdm(os.listdir("./data/" + FLAGS.project + "/" + folder)):
            if filename == ".DS_Store":
                continue

            # Clean filename
            oldname = os.path.join(basefolder, filename)
            fileext = os.path.splitext(oldname)[1]
            newname = os.path.join(
                basefolder,
                os.path.splitext(filename)[0][:30].replace(" ", "-").replace(".", "-").replace("_","-").replace("--","-").replace("$", "").replace("?", "").
                    replace("=","").replace("~", "").replace("%", "").replace("+", "").replace(",","") + fileext
            )
            if oldname != newname:
                # print("Renamed " + oldname)
                os.rename(oldname, newname)

            # Delete pictures more than 200000 or resize
            # if os.path.getsize(newname) > 200000:
                # print("Resizing " + newname)
                # os.remove(newname) nothing planned

            # Remove those that are not images
            filetype = magic.from_file(newname, mime=True)[:5]
            # Remove those that are not PNG / JPG / JPEG
            magicext = magic.from_file(newname, mime=True)[6:]

            if filetype != 'image' or not (fileext == '.jpg' or fileext == '.png' or fileext == '.jpeg') or not (magicext == 'jpeg' or magicext == 'png'):
                os.remove(newname)
