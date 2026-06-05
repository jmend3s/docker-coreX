FROM [OS]

ARG USERNAME=[USERNAME]
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG WORKDIR=[WORKSPACE]

RUN apt-get update && apt-get install -y --no-install-recommends \
        [PACKAGES TO INSTALL]
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN if getent passwd $USER_UID >/dev/null; then userdel -r -f $(getent passwd $USER_UID | cut -d: -f1); fi && \
    if getent group $USER_GID >/dev/null; then groupdel $(getent group $USER_GID | cut -d: -f1); fi && \
    groupadd --gid $USER_GID $USERNAME && \
    useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    mkdir -p /home/$USERNAME/.config && chown -R $USER_UID:$USER_GID /home/$USERNAME

RUN apt-get install -y sudo && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && chmod 0440 /etc/sudoers.d/$USERNAME && rm -rf /var/lib/apt/lists/*

USER $USERNAME
WORKDIR /home/$USERNAME

RUN mkdir -p /home/$USERNAME/$WORKDIR
WORKDIR /home/$USERNAME/$WORKDIR

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["bash"]
