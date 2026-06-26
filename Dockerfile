FROM debian:bookworm-slim

ARG USERNAME=jmendes
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG WORKDIR=zephyr_ws
ARG DEBIAN_FRONTEND=noninteractive
ARG ZEPHYR_VERSION=v4.2.0
ARG ZEPHYR_SDK_VERSION=0.17.0

# ------------------------------------------------------------------
# Base packages
# ------------------------------------------------------------------

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    git \
    cmake \
    ninja-build \
    gperf \
    ccache \
    dfu-util \
    device-tree-compiler \
    wget \
    which \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    python3-dev \
    file \
    make \
    gcc \
    g++ \
    xz-utils \
    bzip2 \
    unzip \
    curl \
    rsync \
    udev \
    usbutils \
    minicom \
    picocom \
    gdb \
    gdb-multiarch \
    openocd \
    libmagic1 \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------
# User
# ------------------------------------------------------------------

RUN groupadd --gid $USER_GID $USERNAME && \
    useradd \
        --uid $USER_UID \
        --gid $USER_GID \
        --create-home \
        --shell /bin/bash \
        $USERNAME

RUN echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" \
    > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME

ENV PATH="/home/$USERNAME/.local/bin:${PATH}"

# ------------------------------------------------------------------
# Python tools
# ------------------------------------------------------------------

RUN pip3 install --break-system-packages --user \
    west \
    pyelftools

# ------------------------------------------------------------------
# Zephyr SDK
# ------------------------------------------------------------------

RUN cd /tmp && \
    wget -q \
    https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_VERSION}/zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-x86_64.tar.xz && \
    tar xf zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-x86_64.tar.xz && \
    sudo mv zephyr-sdk-${ZEPHYR_SDK_VERSION} /opt/zephyr-sdk && \
    rm zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-x86_64.tar.xz

ENV ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk

RUN /opt/zephyr-sdk/setup.sh -t all -h

# ------------------------------------------------------------------
# Zephyr
# ------------------------------------------------------------------

RUN mkdir -p ~/zephyrproject && \
    cd ~/zephyrproject && \
    west init && \
    cd zephyr && \
    git fetch --tags && \
    git checkout ${ZEPHYR_VERSION} && \
    cd .. && \
    west update && \
    west zephyr-export

# ------------------------------------------------------------------
# Zephyr Python dependencies
# ------------------------------------------------------------------

RUN pip3 install --break-system-packages --user \
    -r ~/zephyrproject/zephyr/scripts/requirements.txt

# ------------------------------------------------------------------
# Environment
# ------------------------------------------------------------------

RUN echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc && \
    echo 'export ZEPHYR_BASE=$HOME/zephyrproject/zephyr' >> ~/.bashrc && \
    echo 'export ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk' >> ~/.bashrc

# ------------------------------------------------------------------
# Workspace
# ------------------------------------------------------------------

RUN mkdir -p /home/$USERNAME/$WORKDIR

WORKDIR /home/$USERNAME/$WORKDIR

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["bash"]