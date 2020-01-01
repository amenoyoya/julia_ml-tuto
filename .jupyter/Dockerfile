# Python 3.7 + Debian ベース
FROM python:3.7-slim-buster

# Docker実行ユーザID取得
ARG UID

# JupyterNotebook と Julia 1.3 インストール
WORKDIR /usr/src/
RUN apt update && apt upgrade -y && \
    apt install -y wget && \
    pip install --upgrade pip && \
    : 'Install jupyter, pytorch' && \
    pip install jupyter torch torchvision && \
    wget -O - https://julialang-s3.julialang.org/bin/linux/x64/1.3/julia-1.3.1-linux-x86_64.tar.gz | tar xvzf - && \
    ln -s /usr/src/julia-1.3.1/bin/julia /usr/local/bin/julia && \
    : 'jupyterユーザ追加（ユーザIDをDocker実行ユーザIDと合わせる）' && \
    useradd -u $UID -m jupyter && \
    : 'jupyterユーザをsudoersに追加' && \
    echo 'jupyter ALL=(ALL) NOPASSWORD:ALL' >> /etc/sudoers && \
    : 'jupyterユーザのパスワードを`password`に変更' && \
    echo 'jupyter:password' | chpasswd

# 作業者: jupyterユーザ
USER jupyter

# 作業ディレクトリ: /var/www/app/ => host://./
WORKDIR /var/www/app

# JupyterNotebook設定
COPY ./jupyter_notebook_config.py /home/jupyter/.jupyter/

# Juliaパッケージのインストール
RUN : 'Install JupyterNotebook Julia kernel' && \
    julia -e 'using Pkg; Pkg.add("IJulia")' && \
    : 'Install other Julia packages' && \
    julia -e 'using Pkg; Pkg.add("HTTP"); Pkg.add("DataFrames"); Pkg.add("Match"); Pkg.add("PyCall"); Pkg.add("Images"); Pkg.add("ImageMagick"); Pkg.add("Nettle");'
    