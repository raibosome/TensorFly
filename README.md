# Image scraper

This is an end-to-end-ish pipeline of an image recognition task using **transfer learning**, running on TensorFlow framework. This project is designed to be _lite_ (intentional spelling) for _fast prototyping_ (as if prototyping isn't fast enough). So I minimised touchpoints by abstracting them into make commands.

Not the kind of housefly but 'TensorFly' because I was training this on aeroplane images. I have also created TensorFood and TensorBug for classifying food and bugs respectively.

## 0. Download Libraries and Drivers

Prepare `data/`, `tf_files/`, `static/` folders

``` bash
make prepare
```

1. TensorFlow: `tensorflow==1.8.*`
2. [Chrome Driver](https://sites.google.com/a/chromium.org/chromedriver/downloads)
3. TensorFlow Lite: `tensorflow==1.7.*` (optional)
4. TensorFlow Mobile iOS:`tensorflow==1.1.*` (optional)

## 1. Download Data

1. Go to the `Queries` and enter your, you guessed it, Google queries, one for every line.
2. Edit `config/download.json` accordingly. By default, you will have 350 images for every class.
3. Run
    ``` bash
    make download
    ```
    This downloads your queries into folders of images in the `data/` folder.
4. Rename your folders.

```bash
cat download_images/Queries >> logs/queried
echo >> logs/queried	# newline character spacing
python scripts/scraper_maker.py --project=${PROJECT}
googleimagesdownload -cf logs/scraper.json
$(TELL) "Sir are you there? The image downloads are ready. Cleaning folders and images now."
make clean
```

```bash
python scripts/image_cleaner.py
$(TELL) "Folders and images are now cleaned."
```