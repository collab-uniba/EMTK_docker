# EMTK_docker
Dockerfile for building the EMTk image

### Latest tag version
`0.2.2` (2019-05-21)

### Instructions
First, execute the Docker container in interactive mode. By default, the instruction below will execute the `latest` version.

```bash
# docker run --rm -it collabuniba/emtk
```


##### Polarity module

The `-it` option starts the container in the interactive mode, so the `run` command logs you in the container’s shell environment (`>`). From there, to execute the polarity module, run:

```bash
> emtk polarity -F A -i input.csv -oc output.csv -vd 600 [-W dsm.bin] [-L] [-ul unigramList -bl bigramList]
```

where:

- `-F {A, S, L, K}`, feature to evaluate `A` for All, S for Semantic, `L` for Lexicon, `K` for Keyword.
- `-i <input.csv>`: the input data to classify. 
- `-oc <output.csv>`: the resulting predictions. 
- `-vd <N>`: the vector size.
- `-W <dsm.bin>`: [optional] the wordspace to use; the default wordspace is `/polarity/ClassificationTask/dsm.bin`.
- `-L`: [optional] if present, the input corpus comes with a gold label in the label column.
- `-ul <filename>`: [optional] the unigram's list.
- `-bl <filename>`: [optional] the bigram's list.

Users can test-drive the polarity module by using the file `/polarity_sample.csv`, containing only a handful of documents.

##### Emotion module

Regarding the emotion classifier module, in the following, we show first how to train a new model and, then, how to test it on unseen data. To train a new model on a training set, run:

```bash
> emtk emotions train -i file.csv -d delimiter [-g] -e emotion
```

where:

- `-i <file.csv>`: the corpus to be classified, encoded in UTF-8 without BOM and with the following format:

- ```
  id;label;text
  …
  22;NO;"""Excellent! This is exactly what I needed. Thanks!"""
  23;YES;"""FEAR!!!!!!!!!!!"""
  …
  ```

- `-d {c, sc}`: the delimiter used in the csv file, where c stands for comma and sc for semicolon.

- `-e {joy, anger, sadness, love, surprise, fear}`: the emotion to be detected.

As a result, the script will generate an output folder in the present working directory named `training_<file.csv>_<emotion>/`, containing:

- `n-grams/`: a subfolder containing the extracted n-grams.
- `idfs/`: a subfolder containing the IDFs computed for n-grams and WordNet Affect emotion words.
- `feature-<emotion>.csv`: a file with the features extracted from the input corpus and used for training the model.
- `liblinear/DownSampling/` and `liblinear/NoDownSampling/`, two folders each containing:
  - `trainingSet.csv` and `testSet.csv`.
  - eight models trained with `liblinear model_<emotion>_<ID>.Rda`, where ID refers to the liblinear model (with values in {0, ..., 7}).
  - `performance_<emotion>_<IDMODEL>.txt`, a file containing the results of the parameter tuning for the model (cost), the confusion matrix, and the Precision, Recall, and F-measure for the best cost for the specific `<emotion>`.
  - `predictions_<emotion>_<IDMODEL>.csv`, containing the test instances with the predicted labels for the specific `<emotion>`.

Finally, to execute the classification task, run:

```bash
> emtk emotions classify -i file.csv -d delimiter -e emotion [-m model] [-f /path/to/.../idfs] [-o /path/to/.../ngrams] [-l]
```

where:

- `-i <file.csv>`: same as above.
- `-p`: enables the extraction of features regarding politeness, mood and modality.
- `-d {c, sc}`: same as above.
- `-e {joy, anger, sadness, love, surprise, fear}`: same as above.
- `-m model`: [optional] the model file learned during the training step; if not specified, as default the model learned on the Stack Overflow gold standard will be used.
- `-f /path/to/.../idfs`: [optional] with custom models, also the path to the folder containing the dictionaries with IDFs computed during the training step is required; the folder must include IDFs for n-grams (uni- and bi-grams) and the WordNet Affect lists of emotion words.
- `-o /path/to/.../ngrams`: [optional] with custom models, also the path to the folder containing the dictionaries extracted during the training step; the folder must include n-grams (i.e., UnigramsList.txt and BigramsList.txt).
- `-l`: [optional] if present, the input corpus comes with a gold label in the column label.

As a result, the script will create an output folder in the present working directory named `classification_<file.csv>_<emotion>`, containing:

- `predictions_<emotion>.csv`: a csv file, containing a binary prediction (yes/no) for each line of the input corpus:

- ```
  id;predicted
  …
  22;NO
  23;YES
  …
  ```

- `performance_<emotion>.txt`: a file containing several performance metrics (Precision, Recall, F1, confusion matrix), created only if the input corpus `<file.csv>` contains the column label.

Users can test-drive the emotion classification module by using the file `/emotions_sample.csv`, which contains only a handful of documents. Other more complex sample datasets are available at `/emotions/java/DatasetSO/StackOverflowCSV`.

##### The `/shared/` folder

To use the EMTk modules with **custom datasets**, users must access the `/shared/` folder, which is mounted specifying the `–v`  option in the `docker run` command shown above. The `-v` option defines the paths for the folder to be shared in both the host and the hosted machines:

`docker run -v <pathInTheHostMachine>:<pathInTheContainer> [...]`.

For instance, on a Linux machine, `-v ~/shared:/shared` creates a folder named `shared` in the host system's home (if it doesn't already exist) and a folder named `shared` in the container's root. Whatever is put into the shared folder can be found on both the systems, allowing input and output file exchange. This is accomplished leveraging [Docker's bind mounts](https://docs.docker.com/storage/bind-mounts/).

