# Ubuntu Dockerfile
#
# https://github.com/dockerfile/ubuntu
#

# Pull base image.
FROM ubuntu:14.04

# Install.
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential pkg-config apt-utils libncurses-dev libreadline-dev sqlite3 && \
  apt-get install -y git wget mercurial libssl-dev libfreetype6-dev libxft-dev libsqlite3-dev openssl && \
  apt-get install -y libjpeg-dev liblapack-dev gfortran python-opencv libbz2-dev && \
  apt-get install -y cmake libjpeg8-dev libtiff4-dev libjasper-dev libpng12-dev libgtk2.0-dev && \
  apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libatlas-base-dev gfortran

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

RUN hg clone https://hg.python.org/cpython
RUN git clone https://github.com/dimart/pokemon_recognition.git
RUN git clone https://github.com/Itseez/opencv.git
RUN git clone https://github.com/Itseez/opencv_contrib.git
RUN wget https://raw.githubusercontent.com/kuleshov/cs228-material/master/tutorials/python/cs228-python-tutorial.ipynb

# see http://stackoverflow.com/questions/22157184/strange-python-compilation-results-with-enable-shared-flag for LD_RUN_PATH logic with fixes bug related to --enable-shared below

RUN set -x \
    && cd /root/cpython/ \
    && hg checkout -r v2.7.13 \
    && ./configure --enable-shared \
    && LD_RUN_PATH=/usr/local/lib make \
    && make install \
    && python -m ensurepip \
    && pip install pip --upgrade \
    && pip install virtualenv --upgrade \
    && pip install jupyter[all] --upgrade \
    && pip install matplotlib --upgrade \
    && pip install Pillow --upgrade \
    && pip install SciPy --upgrade \
    && pip install sklearn --upgrade \
    && pip install bunch --upgrade \
    && pip install scikit-image --upgrade
#    && rm -rf /root/cpython/.hg \
RUN set -x \
    && ln -s /usr/lib/python2.7/dist-packages/cv2.so /usr/local/lib/python2.7/site-packages/ \
    && cd /root/opencv_contrib/ \
    && git checkout 3.1.0 \
    && cd /root/opencv/ \
    && git checkout 3.1.0 \
    && mkdir build \
    && cd build \
    && cmake -D OPENCV_EXTRA_MODULES_PATH=/root/opencv_contrib/modules -D WITH_FFMPEG=OFF ..\
    && make -j6 \
    && make install \
    && ldconfig 
RUN set -x \
    && cd /root/cpython/ \
    && hg checkout -r v3.6.0 \
    && make clean \
    && ./configure --enable-shared \
    && cp Modules/Setup.dist Modules/Setup \ 
    && make touch \
    && LD_RUN_PATH=/usr/local/lib make \
    && make install \
    && pip3 install jupyter \
    && python2 -m pip install ipykernel \
    && python2 -m ipykernel install --user \
    && python3 -m pip install ipykernel \
    && python3 -m ipykernel install --user \
    && cd /root

#from http://www.kdnuggets.com/2016/04/top-10-ipython-nb-tutorials.html

RUN git clone https://github.com/jakevdp/sklearn_tutorial.git \
    && git clone https://github.com/masinoa/machine_learning.git \
    && git clone https://github.com/craffel/theano-tutorial.git

ADD ./PhotoTest.ipynb /root/PhotoTest.ipynb
ADD ./Pokemon.ipynb /root/Pokemon.ipynb
ADD ./skimage_examples.ipynb /root/skimage_examples.ipynb
ADD ./OpenCV.ipynb /root/OpenCV.ipynb
ADD ./OpenCV_Recognize.ipynb /root/OpenCV_Recognize.ipynb
ADD ./Words_Letters_Recognize.ipynb /root/Words_Letters_Recognize.ipynb
ADD ./Screenshot_2016-02-23-12-47-43.png /root/Screenshot_2016-02-23-12-47-43.png
ADD ./SciKit-Image.ipynb /root/SciKit-Image.ipynb
ADD ./HighLevelGraphicsJupyter.ipynb /root/HighLevelGraphicsJupyter.ipynb
ADD ./Ipython_core_debug_Trace.ipynb /root/Ipython_core_debug_Trace.ipynb
ADD ./Quandl_and_csv.ipynb /root/Quandl_and_csv.ipynb

# From http://jupyter-notebook.readthedocs.org/en/latest/public_server.html
# Add Tini. Tini operates as a process subreaper for jupyter. This prevents
# kernel crashes.
ENV TINI_VERSION v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]
 
EXPOSE 8888

# Define default command.
CMD ["/usr/local/bin/jupyter", "notebook", "--allow-root", "--no-browser", "--port=8888", "--ip=*"]
