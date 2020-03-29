# Image scraper

Tool to scrape images from Google and clean the images.

1. Download [Chrome Driver](https://sites.google.com/a/chromium.org/chromedriver/downloads).

2. Go to the `Queries` and enter your Google queries, one for every line.

3. Download

    This downloads your queries into folders of images in the `data/` folder.

    ```bash
    cat Queries >> logs/queried.txt
    echo >> logs/queried
    python scrape.py --project=${PROJECT}
    googleimagesdownload -cf logs/scraper.json
    ```

4. Clean

    ```bash
    python cleaner.py
    $(TELL) "Folders and images are now cleaned."
    ```
