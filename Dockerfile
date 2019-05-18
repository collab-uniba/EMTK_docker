FROM python:2.7

# Install Git LFS
RUN echo 'deb http://http.debian.net/debian stretch-backports main' > /etc/apt/sources.list.d/stretch-backports-main.list && \
	curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
	apt-get -y update && \
	apt-get -y install git-lfs && \
	git lfs install

# ============================================= #
# Clone the datasets and projects' repositories #
# ============================================= #

# Dataset
RUN git clone https://github.com/collab-uniba/EMTK_datasets.git datasets

# Emotions
RUN git clone https://github.com/collab-uniba/Emotion_and_Polarity_SO.git emotions
RUN wget -P /emotions/java/lib http://nlp.stanford.edu/software/stanford-corenlp-models-current.jar

# Polarity
RUN git lfs clone https://github.com/collab-uniba/Senti4SD.git polarity


# ====== #
# PYTHON #
# ====== #

# Install python requirements
COPY requirements.txt /
RUN pip install --upgrade pip && \
    pip install -r /requirements.txt
RUN python -m nltk.downloader all
RUN rm requirements.txt


# ==== #
# JAVA #
# ==== #

# Install Java 8 JRE
RUN apt-get -y update && \
    apt-get -y install default-jre


# ====== #
# R-base #
# ====== #

# Install R
RUN apt-get -y update && \
    apt-get -y install r-base

# Install R requirements
COPY requirements.R /
RUN Rscript requirements.R
RUN rm requirements.R

# ========== #
# ENTRYPOINT #
# ========== #

# Copy the main bash script onto the image and make it a command
COPY ./emtk /
RUN cp /emotions/sample.csv /emotions_sample.csv
RUN cp /polarity/ClassificationTask/Sample.csv /polarity_sample.csv
RUN ln -s /emtk /usr/bin/emtk

# Run the bash inside the container when it starts
ENTRYPOINT [ "/bin/bash" ]