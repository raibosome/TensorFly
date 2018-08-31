# TensorFly

This is an end-to-end-ish pipeline of an image recognition task using **transfer learning**, running on TensorFlow framework. This project is designed to be _lite_ (intentional spelling) for _fast prototyping_ (as if prototyping isn't fast enough). So I minimised touchpoints by abstracting them into make commands.

Not the kind of housefly but 'TensorFly' because I was training this on aeroplane images. I have also created TensorFood and TensorBug for classifying food and bugs respectively. These are on http://qwivel.com.

## -1. Project Directory

``` bash
├── Makefile           List of make commands
├── Queries            To download data
├── app.py             Flask app
├── config             Configuration files
├── data               Downloaded images go here
├── logs               History of your queries
├── requirements.txt   Libraries needed
├── scripts            All Python scripts
├── static             Flask app: test images
├── templates          Flask app: HTML files
└── tf_files
    ├── bottlenecks         Precalculated values for each image
    ├── models_retrained    Protobuf file and labels
    └── training_summaries  Event files of models
```

Prepare `data/` and `tf_files/` folders

```
make prepare
```

## 0. Download Libraries and Drivers

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

## 1. Train Model

1. Edit model in `config/training.sh`. (Do note that to deploy your model in iOS, your architecture must not be too 'heavy'.)
2. Run
    ``` bash
    source config/training.sh
    make train
    ```
3. The above command also sets up TensorBoad to show the cross entropy losses. See http://localhost:6006.

## 2. Run Inference

Alas not TensorFlow Serving. Just a simple Flask app.

``` bash
make app
```

<!-- ## 3. Mobile Deployment (Optional)

Note that this only works if your model is MobileNet.

Note that the last line is specifically for deploying TF Mobile on iOS. To do this, create a conda environment with TensorFlow v1.1 installed, and call it `tensorflowmobileios`. Then:

```bash
source activate tensorflowmobileios
make train_tfmobileios
source deactivate
```

### Serialising the Graph

Serialise the `GraphDef` ProtoBuf file to give `optimized_graph.pb`. Last line is optional - quantising the ProtoBuf file to give `rounded_graph.pb`.

```bash
make optimise_pb
make quantize_android_pb
```

Alternatively, we can serialise the `GraphDef` to FlatBuffers, giving us `optimized_graph.lite`.

```bash
source activate tensorflowlite
make optimize_fb
source deactivate
```

### Android: TensorFlow Mobile

```bash
make optimize_pb
make export_tfmobile_to_android
```

### Android: TensorFlow Lite

```bash
make export_tflite_to_android
AndroidStudio android/tflite
```

### iOS: TensorFlow Mobile

```bash
source activate tensorflowmobileios
make train_tfmobileios
source deactivate
make export_tfmobile_to_ios
open ios/tfmobile/*.xcworkspace
```

### iOS: TensorFlow Lite

```bash
make export_tflite_to_ios
pod update
open ios/tflite/*.xcworkspace
``` -->

## Appendix A: Image Models in TensorFlow Hub

We're lucky to have a myriad of things to choose from: (a) model; (b) model version; (c) model size; (d) option for quantisation; and (e) dataset on which the model was trained on.

| Model Name        | Model Version | Model Size        | Input Sizes           | Pretrained On   | Quantisation Option   | Update Version
| ----------------- | ------------- | ----------------- | --------------------- | --------------------- | --------------------- | -------------
| `inception`       | `v1`          | -                 | `224`                 | `imagenet`              | -                     | `1`
|                   | `v2`          | -                 | `299`                 | `imagenet`              | -                     | `1`
|                   | `v3`          | -                 | `299`                 | `imagenet`, `inaturalist`^ | -                     | `1`
| `inception_resnet` | `v2`         | -                 | `299`                 | `imagenet`              | -                     | `1`
| `mobilenet`       | `v1`          | depth: `100`, `75`, `50`, `25`   | `224`, `192`, `160`, `128`    | `imagenet`              | Yes   | `1`
|                   | `v2`          | depth: `140`, `130`, `100`, `75`, `50`, `35` | `224`, `192`, `160`, `128`, `96` | `imagenet` | - | `2`
| `nasnet`          | `large`, `mobile` | -             | `331`                 | `imagenet`              | -                     | `1`
| `pnaset`          | `large`       | -                 | `331`                 | `imagenet`              | -                     | `2`
| `resnet`          | `v1`, `v2`    | layers: `50`, `101`, `152` | `224`        | `imagenet`              | -                     | `1`

To use Inception V3 pretrained on ImageNet, set the following in `config/training.sh` before training.

``` bash
export MODEL="inception_v3"
export PRETRAINED_ON="imagenet"
export UPDATE_VERSION=1
export INPUT_WIDTH=299
```

ImageNet: ILSVRC-2012-CLS<br>
^The weights for this module were obtained by training on the iNaturalist (iNat) 2017 dataset, after pre-training on ImageNet.

Visit [TensorFlow Hub for Image Modules](https://www.tensorflow.org/hub/modules/image).

## Appendix B: Model Specifications

WIP

| Model             | Version   | Input Size    | No. of Parameters | Penultimate Layer Size | Feature | Published |
| ----------------- | --------- | ------------- | ----------------- | ---------------------- | - | -
| Inception         | v1        | 224           | 6.6M              | 1024 | | 2014
|                   | v2        | 299           | 11.2M             | 1024 | Batch norm | 2014
|                   | v3        | 299           | 23.8M             | 2048 | | 2015
| Inception-ResNet  | v2        | 299           | 55.8M             | 1536 | | 2016
| MobileNet         | v1        | 128-224       | 4.2M?             | 1280
|                   | v2        | 96-224        | 3.3M              |
| NASNet-A          | large     | 331           |           | 4032 | | 2017
|                   | mobile    | 224           |           | 1056 | | 2017
| PNASNet-5         | large     | 331           |           | 4320 | | 2017
| ResNet            | v1        | 224           | 60.3M (152) (?)                  | 2048 | | 2015
|                   | v2        | 224           |           | 2048 | Batch norm | 2016
