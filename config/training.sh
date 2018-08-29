# Paths
export PATH_EVALUATE_JPEG="/Users/raimibinkarim/Desktop/evaluation/eval.jpeg"
export PATH_EVALUATE_JPG="/Users/raimibinkarim/Desktop/evaluation/eval.jpg"

# Data
export CLASSES=$(ls data | wc -l | xargs)

# Architecture
export MODEL="nasnet_large"
# Models available:
# inception_{v1,v2,v3}
# inception_resnet_v2
# nasnet_{large,mobile}
# pnasnet_large
# resnet_{v1,v 2}_{50,101,152}
# mobilenet_{v1,v2}_{100,075,050,025}_{224,192,160,128}
export PRETRAINED_ON="imagenet"
# Dataset which the above model was trained on:
# imagenet
# inaturalist (only for inception_v3)
export UPDATE_VERSION=1
export INPUT_WIDTH=331
export INPUT_HEIGHT=${INPUT_WIDTH}
export TFHUB_MODULE="https://tfhub.dev/google/${PRETRAINED_ON}/${MODEL}/feature_vector/${UPDATE_VERSION}"

# Training
export TRAINING_STEPS=1000 #4000
export LEARNING_RATE=0.05 #0.05
export TRAIN_BATCH_SIZE=100 #100
export VALIDATION_BATCH_SIZE=-1 #100, -1
export CROP=0
export SCALE=0
export BRIGHTNESS=0

# remember to run `source config
export MODEL_ID=${MODEL}_${CLASSES}classes_${TRAINING_STEPS}steps_${TRAIN_BATCH_SIZE}batch_${LEARNING_RATE}L_${CROP}C_${SCALE}S_${BRIGHTNESS}B