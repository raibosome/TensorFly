.PHONY : folders, reset, data, tensorboard, train, optimize, quantize, summarize, evaluate, test, speech

# Prepare folders
folders :
	mkdir tf_files/photos

reset :
	rm -r tf_files/*
	make folders

# Copy data to respective folders
data :
	cp -r ${PATH_DATA}/downloads/* tf_files/photos

tensorboard :
	tensorboard --logdir tf_files/training_summaries &

tensorboard_kill :
	pkill -f "tensorboard"

# Check variables
variables :
	echo ${IMAGE_SIZE}
	echo ${MODEL_SIZE}
	echo ${ARCHITECTURE}
	echo ${TRAINING_STEPS}
	echo ${LEARNING_RATE}
	echo ${TRAIN_BATCH_SIZE}

train :
	# remember to run `source config
	make tensorboard
	python -m scripts.retrain \
	  --image_dir=tf_files/photos \
	  --bottleneck_dir=tf_files/bottlenecks \
	  --model_dir=tf_files/models/ \
	  --summaries_dir=tf_files/training_summaries/${ARCHITECTURE}_${TRAINING_STEPS}_${TRAIN_BATCH_SIZE}_${LEARNING_RATE} \
	  --output_graph=tf_files/retrained_graph.pb \
	  --output_labels=tf_files/retrained_labels.txt \
	  --architecture="${ARCHITECTURE}" \
	  --how_many_training_steps=${TRAINING_STEPS}  \
	  --learning_rate=${LEARNING_RATE} \
	  --train_batch_size=${TRAIN_BATCH_SIZE}
	make speech

speech :
	say "Hello sir. Training for ${ARCHITECTURE} is now complete. Please come to the computer to continue."

train_tfmobileios :
	# remember to run `source config
	# remember to set env to use TF 1.1: source activate tensorflowmobileios
	make tensorboard
	python -m scripts.retrain \
	  --image_dir=tf_files/photos \
	  --bottleneck_dir=tf_files/bottlenecks \
	  --model_dir=tf_files/models/ \
	  --summaries_dir=tf_files/training_summaries/${ARCHITECTURE}_tfmobileios_${TRAINING_STEPS}_${TRAIN_BATCH_SIZE}_${LEARNING_RATE} \
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
	--inference_type=FLOAT \
	--input_data_type=FLOAT

compress : 
	gzip -c tf_files/optimized_graph.pb > tf_files/optimized_graph.pb.gz
	gzip -c tf_files/rounded_graph.pb > tf_files/rounded_graph.pb.gz
	gzip -l tf_files/optimized_graph.pb.gz
	gzip -l tf_files/rounded_graph.pb.gz

evaluate :
	python -m scripts.evaluate tf_files/retrained_graph.pb
	python -m scripts.evaluate tf_files/optimized_graph.pb
	python -m scripts.evaluate tf_files/rounded_graph.pb

test :
	python -m scripts.label_image \
	  --graph=tf_files/retrained_graph_tfmobileios.pb  \
	  --image=/Users/raimibinkarim/Desktop/testing

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

