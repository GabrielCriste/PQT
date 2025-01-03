FROM jupyter/base-notebook:python-3.7.6

# Mudar para o usuário root para instalar pacotes do sistema
USER root

# Atualizar pacotes do sistema e instalar dependências necessárias
RUN apt-get -y update && apt-get install -y \
    dbus-x11 \
    firefox \
    xfce4 \
    xfce4-panel \
    xfce4-session \
    xfce4-settings \
    xorg \
    xubuntu-icon-theme && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar TurboVNC
ARG TURBOVNC_VERSION=2.2.6
RUN wget -q "https://sourceforge.net/projects/turbovnc/files/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb/download" -O turbovnc_${TURBOVNC_VERSION}_amd64.deb && \
    apt-get install -y -q ./turbovnc_${TURBOVNC_VERSION}_amd64.deb && \
    apt-get remove -y -q light-locker && \
    rm ./turbovnc_${TURBOVNC_VERSION}_amd64.deb && \
    ln -s /opt/TurboVNC/bin/* /usr/local/bin/

# Corrigir permissões para o diretório HOME do usuário
RUN chown -R $NB_UID:$NB_GID $HOME

# Adicionar arquivos de instalação ao contêiner
ADD . /opt/install
RUN fix-permissions /opt/install

# Instalar Mamba no ambiente base
RUN conda install -n base -c conda-forge mamba && mamba clean --all -f -y

# Voltar para o usuário padrão do Jupyter Notebook
USER $NB_USER

# Copiar o arquivo environment.yml para o contêiner
COPY --chown=$NB_UID:$NB_GID environment.yml /tmp

# Usar Mamba para instalar as dependências definidas no environment.yml
RUN mamba env update --quiet --file /tmp/environment.yml && \
    mamba clean --all -f -y
    
