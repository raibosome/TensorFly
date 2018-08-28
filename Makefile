.PHONY : heyyy, clean, folders, reset, download, tensorboard, train, optimize, quantize, summarize, evaluate, test, speech, export

download :
	cat Queries >> logs/queried
	echo >> logs/queried	# newline character spacing
	python scripts/scraper_maker.py
	googleimagesdownload -cf logs/scraper.json
	say "Sir are you there? The image downloads are ready. Cleaning folders and images now."
	make clean

clean :
	python scripts/image_cleaner.py
	say "Folders and images are now cleaned."

reset :
	rm -rf tf_files/bottlenecks/* tf_files/training_summaries/*

tensorboard :
	tensorboard --logdir tf_files/training_summaries &

tensorboard-kill :
	pkill -f "tensorboard"

train :
	# remember to run `source config
	make tensorboard
	python -m scripts.retrain_latest \
	  --image_dir=data/ \
	  --bottleneck_dir=tf_files/bottlenecks/${MODEL}  \
	  --summaries_dir=tf_files/training_summaries/${MODEL_ID} \
	  --output_model=tf_files/models_retrained/${MODEL_ID} \
	  --output_graph=tf_files/models_retrained/${MODEL_ID}/retrained_graph.pb \
	  --output_labels=tf_files/models_retrained/${MODEL_ID}/retrained_labels.txt \
	  --how_many_training_steps=${TRAINING_STEPS}  \
	  --learning_rate=${LEARNING_RATE} \
	  --train_batch_size=${TRAIN_BATCH_SIZE} \
	  --validation_batch_size=${VALIDATION_BATCH_SIZE} \
	  --random_crop=${CROP} \
	  --random_scale=${SCALE} \
	  --random_brightness=${BRIGHTNESS} \
	  --tfhub_module=${TFHUB_MODULE}
	say "Hello sir. Training for ${MODEL} is now complete. Please come to the computer to continue."

app :
	python application.py

train_legacy :
	# remember to run `source config
	make tensorboard
	python -m scripts.retrain_latest \
	  --image_dir=data/ \
	  --bottleneck_dir=tf_files/bottlenecks \
	  --model_dir=tf_files/models/ \
	  --summaries_dir=tf_files/training_summaries/${MODULE_NICKNAME}_${CLASSES}classes_${TRAINING_STEPS}steps_${TRAIN_BATCH_SIZE}batch_${LEARNING_RATE}L_${CROP}C_${SCALE}S_${BRIGHTNESS}B \
	  --output_model=tf_files/models_retrained/${MODULE_NICKNAME}_${CLASSES}classes_${TRAINING_STEPS}steps_${TRAIN_BATCH_SIZE}batch_${LEARNING_RATE}L_${CROP}C_${SCALE}S_${BRIGHTNESS}B \
	  --output_graph=tf_files/models_retrained/${MODULE_NICKNAME}_${CLASSES}classes_${TRAINING_STEPS}steps_${TRAIN_BATCH_SIZE}batch_${LEARNING_RATE}L_${CROP}C_${SCALE}S_${BRIGHTNESS}B/retrained_graph.pb \
	  --output_labels=tf_files/models_retrained/${MODULE_NICKNAME}_${CLASSES}classes_${TRAINING_STEPS}steps_${TRAIN_BATCH_SIZE}batch_${LEARNING_RATE}L_${CROP}C_${SCALE}S_${BRIGHTNESS}B/retrained_labels.txt \
	  --architecture=${ARCHITECTURE} \
	  --how_many_training_steps=${TRAINING_STEPS}  \
	  --learning_rate=${LEARNING_RATE} \
	  --train_batch_size=${TRAIN_BATCH_SIZE} \
	  --random_crop=${CROP} \
	  --random_scale=${SCALE} \
	  --random_brightness=${BRIGHTNESS}
	say "Hello sir. Training for ${MODULE_NICKNAME} is now complete. Please come to the computer to continue."

	

train_tfmobileios :
	# remember to run `source config
	# remember to set env to use TF 1.1: source activate tensorflowmobileios
	make tensorboard
	python -m scripts.retrain \
	  --image_dir=${PATH_DATA} \
	  --bottleneck_dir=tf_files/bottlenecks \
	  --model_dir=tf_files/models/ \
	  --summaries_dir=tf_files/training_summaries/${ARCHITECTURE}_tfmobileios_${CLASSES}_${TRAINING_STEPS}_${TRAIN_BATCH_SIZE}_${LEARNING_RATE} \
	  --output_graph=tf_files/retrained_graph_tfmobileios.pb \
	  --output_labels=tf_files/retrained_labels.txt \
	  --architecture="${ARCHITECTURE}" \
	  --how_many_training_steps=${TRAINING_STEPS}  \
	  --learning_rate=${LEARNING_RATE} \
	  --train_batch_size=${TRAIN_BATCH_SIZE}
	

# serialise graphdef to protobuf
optimize_pb :
	python -m tensorflow.python.tools.optimize_for_inference \
	  --input=tf_files/retrained_graph.pb \
	  --output=tf_files/optimized_graph.pb \
	  --input_names="input" \
	  --output_names="final_result"

quantize_android_pb :
	python -m scripts.quantize_graph \
	  --input=tf_files/optimized_graph.pb \
	  --output=tf_files/rounded_graph.pb \
	  --output_node_names=final_result \
	  --mode=weights_rounded

# strip the model. need to be in ~/Library/tensorflow
# strip_ios_pb :
	# bazel-bin/tensorflow/tools/graph_transforms/transform_graph \
	# —-inputs="input" \
	# —-in_graph=retrained_graph.pb \
	# —-outputs="final_result" \ 
	# —-out_graph=tmp/quantized_graph.pb \
	# —-transforms='add_default_attributes strip_unused_nodes(type=float, shape="1,${IMAGE_SIZE},${IMAGE_SIZE},3") remove_nodes(op=Identity, op=CheckNumerics) fold_constants(ignore_errors=true) fold_batch_norms fold_old_batch_norms quantize_weights strip_unused_nodes sort_by_execution_order'

# serialise graphdef to flatbuffer
optimize_fb :
	IMAGE_SIZE=224
	toco \
	--input_file=tf_files/retrained_graph.pb \
	--output_file=tf_files/optimized_graph.lite \
	--input_format=TENSORFLOW_GRAPHDEF \
	--output_format=TFLITE \
	--input_shape=1,${IMAGE_SIZE},${IMAGE_SIZE},3 \
	--input_array=input \
	--output_array=final_result \
	--input_data_type=FLOAT
	--inference_type=FLOAT \

optimize_fb_supernew :
	IMAGE_SIZE=224
	toco \
	--input_file=tf_files/retrained_graph.pb \
	--output_file=tf_files/optimized_graph.lite \
	--input_format=TENSORFLOW_GRAPHDEF \
	--output_format=TFLITE \
	--input_shapes=1,${IMAGE_SIZE},${IMAGE_SIZE},3
	--input_array=input \
	--output_array=final_result \
	--input_data_type=FLOAT \
	--inference_type=FLOAT \

compress : 
	gzip -c tf_files/optimized_graph.pb > tf_files/optimized_graph.pb.gz
	gzip -c tf_files/rounded_graph.pb > tf_files/rounded_graph.pb.gz
	gzip -l tf_files/optimized_graph.pb.gz
	gzip -l tf_files/rounded_graph.pb.gz

evaluate :
	python -m scripts.evaluate tf_files/retrained_graph.pb
	python -m scripts.evaluate tf_files/optimized_graph.pb
	python -m scripts.evaluate tf_files/rounded_graph.pb

test-jpg :
	python -m scripts.label_image \
	  --graph=tf_files/retrained_graph.pb  \
	  --image=${PATH_EVALUATE_JPG}

test-jpeg :
	python -m scripts.label_image \
	  --graph=tf_files/models_retrained/${MODEL_ID}/retrained_graph.pb  \
	  --labels=tf_files/models_retrained/${MODEL_ID}/retrained_labels.txt  \
	  --input_layer=Placeholder \
	  --output_layer=final_result \
	  --input_height=${INPUT_HEIGHT} \
	  --input_width=${INPUT_WIDTH} \
	  --image=${PATH_EVALUATE_JPEG}

export :
	make export_tflite_to_android
	make export_tfmobile_to_android
	make export_tfmobile_to_ios
	make export_tflite_to_ios
	make export_tflite_to_ios_supernew

export_tfmobile_to_android :
	cp tf_files/rounded_graph.pb android/tfmobile/assets/graph.pb
	cp tf_files/retrained_labels.txt android/tfmobile/assets/labels.txt 

export_tflite_to_android :
	cp tf_files/optimized_graph.lite android/tflite/app/src/main/assets/graph.lite 
	cp tf_files/retrained_labels.txt android/tflite/app/src/main/assets/labels.txt 	
	
export_tfmobile_to_ios :
	cp tf_files/retrained_graph_tfmobileios.pb ios/tfmobile/data/graph.pb
	cp tf_files/retrained_labels.txt ios/tfmobile/data/labels.txt

export_tflite_to_ios :
	cp tf_files/optimized_graph.lite ios/tflite/data/graph.lite
	cp tf_files/retrained_labels.txt ios/tflite/data/labels.txt

export_tflite_to_ios_supernew :
	cp tf_files/optimized_graph.tflite ios/tflite2/data/graph.tflite
	cp tf_files/retrained_labels.txt ios/tflite2/data/labels.txt

