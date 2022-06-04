# Julia 1.6.1 + Debian ベース
FROM julia:1.6.1-buster

# パッケージインストール時に対話モードを実行しないように設定
ENV DEBIAN_FRONTEND=noninteractive

RUN : 'install japanese environment' && \
    apt-get update && apt install -y tzdata locales-all && \
    : 'install development modules' && \
    apt-get install -y sudo wget curl git unzip vim && \
    : 'cleanup apt-get caches' && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 日本語環境に設定
ENV TZ Asia/Tokyo
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8

# 作業ディレクトリ: /work/ => host://./
WORKDIR /work

# スタートアップコマンド（docker up の度に実行される）
CMD /bin/bash -E ./x startup