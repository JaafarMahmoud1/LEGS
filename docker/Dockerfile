# ------------------------------------------------------------------------------
#                              BASE & DEPENDENCIES
# ------------------------------------------------------------------------------
FROM nvcr.io/nvidia/pytorch:23.04-py3 AS base
# FROM dromni/nerfstudio:1.1.1 a

ENV DEBIAN_FRONTEND=noninteractive

# Locale and basic tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    locales \
    && locale-gen en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV TZ=UTC

RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -y tzdata && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    rm -rf /var/lib/apt/lists/*

# Install tiny-cuda-nn
ENV TCNN_CUDA_ARCHITECTURES=86
RUN pip install --no-cache-dir ninja git+https://github.com/NVlabs/tiny-cuda-nn/#subdirectory=bindings/torch

# ------------------------------------------------------------------------------
#                            INSTALL ROS 2 FOXY
# ------------------------------------------------------------------------------
ENV ROS_DISTRO=foxy
ENV ROS_ROOT=/opt/ros/${ROS_DISTRO}
ENV ROS_PYTHON_VERSION=3
ENV ROS_VERSION=2
ENV PATH=$ROS_ROOT/bin:$PATH
ENV LD_LIBRARY_PATH=$ROS_ROOT/lib:$LD_LIBRARY_PATH
ENV PYTHONPATH=$ROS_ROOT/lib/python3.8/site-packages:$PYTHONPATH
ENV CMAKE_PREFIX_PATH=$ROS_ROOT:$CMAKE_PREFIX_PATH

# Setup sources and install ROS2 Foxy
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | apt-key add - \
    && echo "deb http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2.list \
    && apt-get update && apt-get install -y \
    ros-${ROS_DISTRO}-desktop \
    python3-colcon-common-extensions \
    python3-argcomplete \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
#                              DEVELOPMENT IMAGE
# ------------------------------------------------------------------------------
FROM base AS dev

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    bash-completion \
    build-essential \
    cmake \
    gdb \
    git \
    pylint3 \
    python3-pip \
    python3-vcstool \
    vim \
    wget \
    python3-autopep8 \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip setuptools wheel \
    && pip install \
    dulwich \
    blinker \
    pydocstyle

# Add ROS2 source to root's .bashrc
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /root/.bashrc

# ------------------------------------------------------------------------------
#                              FULL IMAGE
# ------------------------------------------------------------------------------
FROM dev AS full

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    ros-${ROS_DISTRO}-cv-bridge \
    libglvnd0 \
    libgl1 \
    libglx0 \
    libegl1 \
    libxext6 \
    libx11-6 \
    && rm -rf /var/lib/apt/lists/*

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute
ENV QT_X11_NO_MITSHM=1

RUN pip install \
    pydantic==1.9.0 \
    wandb \
    cryptography \
    pyopenssl

# ROS2 setup for root shell
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /root/.bashrc

COPY ./l3gs /tmp/l3gs

# Entrypoint and workspace setup
COPY ../docker/ros_entrypoint.sh /

WORKDIR /workspace/ros2_ws
COPY ../lifelong_msgs /workspace/ros2_ws/src/lifelong_msgs
RUN source /opt/ros/${ROS_DISTRO}/setup.bash && cd /workspace/ros2_ws && colcon build
RUN source /opt/ros/${ROS_DISTRO}/setup.bash && \
    source install/setup.bash

WORKDIR /tmp/l3gs

RUN pip uninstall -y opencv-python opencv-contrib-python && \
    pip install opencv-python==4.8.0.74 && \
    python3 -m pip install -e .

RUN pip install --upgrade pyOpenSSL cryptography
RUN pip install opencv-python==4.8.0.74
RUN pip install tyro==0.8.12

RUN unset RMW_IMPLEMENTATION && unset ROS_DISTRO

WORKDIR /workspace/l3gs/l3gs


ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["/bin/bash"]
