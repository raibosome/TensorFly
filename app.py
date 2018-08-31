"""
Runs a flask app
"""
import os
from flask import Flask, render_template, request
from werkzeug import secure_filename
from scripts.label_image_app import load_real_time

app = Flask(__name__)

#pylint: disable=C0111


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/prediction', methods=['GET', 'POST'])
def inference():

    if request.method == 'POST':
        # Get file and path to file
        f = request.files['file']
        fname = secure_filename(f.filename)
        f.save("./static/" + fname)
        fullpath = os.path.join(os.getcwd(), "static", fname)

        modelname = os.environ['MODEL_ID']

        # Predict
        top, probs = load_real_time(
            file_name=fullpath,
            model_file="./tf_files/models_retrained/" + modelname + "/retrained_graph.pb",
            label_file="./tf_files/models_retrained/" + modelname + "/retrained_labels.txt")

        return render_template('prediction.html', filename=fname, prediction=top, misc=probs)

    else:
        return 'Error'


if __name__ == '__main__':
    app.debug = True
    app.run(host='0.0.0.0', port=8080)
