FROM sulfurheron/nvidia-cuda:10.0-cudnn7-runtime-ubuntu16.04-2019-07-29

# Set the working directory
WORKDIR /app

# missing these packages which are listed as deps in the pyenv instructions from the below sys deps 
# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
# 
#  libncursesw5-dev
# libxml2-dev libxmlsec1-dev

# Download and add the new NVIDIA GPG key
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/3bf863cc.pub

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    curl \
    git \
    libbz2-dev \
    cmake \
    libffi-dev \
    liblzma-dev \
    libncurses5-dev \
    xdotool \
    net-tools \
    libboost-python-dev \
    libboost-all-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    llvm \
    make \
    tk-dev \
    wget \
    xz-utils \
    zlib1g-dev && \
    apt-get clean

RUN apt-get update && \
    apt-get install -y \
    libncursesw5-dev \
    libxml2-dev \
    libxmlsec1-dev && \
    rm -rf /var/lib/apt/lists/*
    # Bash warning: There are some systems where the BASH_ENV variable is configured to point to .bashrc. On such systems, you should almost certainly put the eval "$(pyenv init - bash)" line into .bash_profile, and not into .bashrc. Otherwise, you may observe strange behaviour, such as pyenv getting into an infinite loop. See #264 for details.

ENV PYTHON_VERSION=3.7.3
ENV PYENV_ROOT=/root/.pyenv
ENV PATH=$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
# ENV PATH="$PYENV_ROOT/bin:$PATH"
RUN echo 'export PYENV_ROOT="/root/.pyenv"' | tee -a /root/.bashrc /root/.profile /root/.bash_profile && \
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' | tee -a /root/.bashrc /root/.profile /root/.bash_profile

# Install pyenv and Python 3.7
RUN git clone https://github.com/pyenv/pyenv.git /root/.pyenv && \
    echo 'eval "$(pyenv init --path)"' | tee -a /root/.bashrc /root/.profile /root/.bash_profile && \
    eval "$(pyenv init --path)"

# Install Python 3.7
RUN pyenv install $PYTHON_VERSION && \
    pyenv global $PYTHON_VERSION && \
    pyenv rehash && \
    curl https://bootstrap.pypa.io/pip/3.7/get-pip.py -o get-pip.py && \
    # eval "$(pyenv init --path)" && \
    # pyenv init && \
    # pyenv shell 3.7.3 && \
    python get-pip.py && \
    rm get-pip.py

# Copy the application code
COPY . /app

# set up the virtual env
# ENV VIRTUAL_ENV=/app/.env
# RUN python -m venv .env
# ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install Python dependencies
RUN pip install -r requirements.txt

CMD ["bash"]

