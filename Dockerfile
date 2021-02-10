FROM ubuntu:20.04
MAINTAINER Erik Daenitz

RUN  apt-get update \
  && apt-get install -y wget \
  && apt-get install -y unzip \
  && apt-get install -y xvfb \
  && apt-get install -y libxtst6 \
  && apt-get install -y libxrender1 \
  && apt-get install -y libxi6 \
  && apt-get install -y socat \
  && apt-get install -y software-properties-common

# Setup IB TWS
RUN mkdir -p /opt/TWS
WORKDIR /opt/TWS
RUN wget -q https://download2.interactivebrokers.com/installers/ibgateway/latest-standalone/ibgateway-latest-standalone-linux-x64.sh
RUN chmod a+x ibgateway-latest-standalone-linux-x64.sh

# Setup  IBController
RUN mkdir -p /opt/IBController/
WORKDIR /opt/IBController/
RUN wget -q https://github.com/ib-controller/ib-controller/releases/download/3.4.0/IBController-3.4.0.zip
RUN unzip ./IBController-QuantConnect-3.2.0.zip
RUN chmod -R u+x *.sh && chmod -R u+x Scripts/*.sh

# Install Java 8
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

WORKDIR /

# Install TWS
RUN yes n | /opt/TWS/ibgateway-latest-standalone-linux-x64.sh

# INSTALL MINICONDA
# downloads Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O Miniconda.sh
bash Miniconda.sh -b  # installs it
rm -rf Miniconda.sh  # removes the installer
export PATH="/root/miniconda3/bin:$PATH"  # prepends the new path

# INSTALL PYTHON LIBRARIES
conda install -y pandas  # installs pandas
conda install -y ipython  # installs IPython shell

# CUSTOMIZATION
cd /root/
wget http://hilpisch.com/.vimrc  # Vim configuration

#CMD yes

# Launch a virtual screen
RUN Xvfb :1 -screen 0 1680x1050x24 2>&1 >/dev/null &
RUN export DISPLAY=:1

ADD runscript.sh runscript.sh
CMD bash runscript.sh
