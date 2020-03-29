.PHONY : config, clean, folders, reset, download, tensorboard, train, optimize, quantize, summarize, evaluate, test, speech, export

TELL=echo

init:
ifeq (, $(shell which say))
	TELL=echo
else
	TELL=say
endif

prepare :
	mkdir data/${PROJECT} tf_files/${PROJECT} tf_files/${PROJECT}/bottlenecks tf_files/${PROJECT}/models_retrained tf_files/${PROJECT}/training_summaries static

download :
	cat download_images/Queries >> logs/queried
	echo >> logs/queried	# newline character spacing
	python scripts/scraper_maker.py --project=${PROJECT}
	googleimagesdownload -cf logs/scraper.json
	$(TELL) "Sir are you there? The image downloads are ready. Cleaning folders and images now."
	make clean

summary :
	echo "Trained on ${MODEL}"

clean :
	python scripts/image_cleaner.py
	$(TELL) "Folders and images are now cleaned."

# reset :
# 	rm -rf tf_files/${PROJECT}/bottlenecks/* tf_files/${PROJECT}/training_summaries/*

tensorboard :
	tensorboard --logdir tf_files/${PROJECT}/training_summaries &

tensorboard-kill :
	pkill -f "tensorboard"

app :
	python app.py




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

