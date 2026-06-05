FROM debian:bookworm-slim

ARG USERNAME=jmendes
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG WORKDIR=zephyr_ws
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo git cmake ninja-build gperf ccache dfu-util device-tree-compiler wget which \
    python3 python3-pip python3-setuptools python3-wheel xz-utils file make gcc g++ \
    udev minicom usbutils curl unzip gdb bzip2 \
    gcc-arm-none-eabi gdb-multiarch teensy-loader-cli \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN if getent passwd $USER_UID >/dev/null; then userdel -r -f $(getent passwd $USER_UID | cut -d: -f1); fi && \
    if getent group $USER_GID >/dev/null; then groupdel $(getent group $USER_GID | cut -d: -f1); fi && \
    groupadd --gid $USER_GID $USERNAME && \
    useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    mkdir -p /home/$USERNAME/.config && chown -R $USER_UID:$USER_GID /home/$USERNAME

RUN apt-get install -y sudo && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && chmod 0440 /etc/sudoers.d/$USERNAME && rm -rf /var/lib/apt/lists/*

# Install ARM GNU Toolchain (full C++ support)
RUN cd /opt && \
    wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2 && \
    tar -xjf gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2 && \
    rm gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2

ENV ZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb
ENV GNUARMEMB_TOOLCHAIN_PATH=/opt/gcc-arm-none-eabi-10.3-2021.10
ENV PATH="/home/$USERNAME/.local/bin:$PATH"

USER $USERNAME
WORKDIR /home/$USERNAME

RUN pip install --break-system-packages --user west pyelftools && echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc

RUN mkdir -p ~/zephyrproject && cd ~/zephyrproject && \
    west init && cd zephyr && git fetch --tags && git checkout v4.2.0 && cd .. && \
    west update && west zephyr-export && \
    echo 'export ZEPHYR_BASE=$HOME/zephyrproject/zephyr' >> ~/.bashrc

RUN mkdir -p /home/$USERNAME/$WORKDIR
WORKDIR /home/$USERNAME/$WORKDIR

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["bash"]
