#!/bin/bash

cd $(dirname $0)
export USER_ID="${USER_ID:-$UID}"
export GROUP_ID="${GROUP_ID:-$GID}"

case "$1" in
"startup")
    # * call from docker-entrypoint (don't call from host shell)

    # setup PATH
    export HOME=/home/worker
    export PATH="$PATH:/usr/local/julia/bin:$HOME/.julia/conda/3/bin:$HOME/.julia/conda/3/lib"
    
    # first time setup
    if [ "$(getent passwd worker)" == "" ]; then
        # setup user.worker
        if [ "$(getent passwd $USER_ID)" != "" ]; then usermod -u $((USER_ID + 1000)) "$(getent passwd $USER_ID | cut -f 1 -d ':')"; fi
        useradd -u $USER_ID -m -s /bin/bash worker
        # setup user.worker.sudo NOPASSWD
        echo 'worker ALL=NOPASSWD: ALL' >> /etc/sudoers
        # setup sudo.user.worker keep PATH env
        sed -i -E 's/^Defaults\s\s*secure_path=.*/Defaults env_keep += "PATH"/' /etc/sudoers

        # Install PyCall.jl, Conda.jl
        sudo -E -u worker /usr/local/julia/bin/julia -e 'using Pkg; Pkg.add("PyCall"); Pkg.add("Conda")'
        # Install JupyterLab
        sudo -E -u worker /usr/local/julia/bin/julia -e 'using Conda; Conda.add("jupyterlab"; channel="conda-forge")'
        sudo -E -u worker /usr/local/julia/bin/julia -e 'using Pkg; Pkg.add("IJulia")'

        # setup .bashrc
        echo 'export PATH="$PATH:/usr/local/julia/bin:$HOME/.julia/conda/3/bin:$HOME/.julia/conda/3/lib"' >> ~worker/.bashrc
        chown worker:worker ~worker/.bashrc
    fi
    
    # start jupyter lab by user.worker
    sudo -E -u worker jupyter lab --port=8888 --ip=0.0.0.0 --ServerApp.token='' --project=@.
    ;;
"init")
    tee .env << \EOS
JUPYTER_PORT=8888
EOS
    tee Dockerfile << \EOS
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
EOS
    tee docker-compose.yml << \EOS
# this docker-compose file must be called from ./x
## Docker volume owner Problem: https://stackoverflow.com/questions/40462189/docker-compose-set-user-and-group-on-mounted-volume

# ver 3.6 >= required: enable '-w' option for 'docker-compose exec'
version: "3.8"

networks:
  # プロジェクト内仮想ネットワーク
  ## 同一ネットワーク内の各コンテナはサービス名で双方向通信可能
  appnet:
    driver: bridge
    # ネットワークIP範囲を指定する場合
    # ipam:
    #   driver: default
    #   config:
    #     # 仮想ネットワークのネットワーク範囲を指定
    #     ## 172.68.0.0/16 の場合、172.68.0.1 ～ 172.68.255.254 のIPアドレスを割り振れる
    #     ## ただし 172.68.0.1 はゲートウェイに使われる
    #     - subnet: 172.68.0.0/16

services:
  # app service container: julia:1.6.1-buster
  ## http://localhost:{JUPYTER_PORT:-8888} => http://app:8888
  app:
    build: ./
    logging:
      driver: json-file
    networks:
      - appnet
    ports:
      - "${JUPYTER_PORT:-8888}:8888"
    # enable terminal
    tty: true
    volumes:
      # host://./ => docker://app:/work/
      - ./:/work/
    environment:
      USER_ID: "${USER_ID:-0}"
      GROUP_ID: "${GROUP_ID:-0}"
EOS
    tee Project.toml << \EOS
name = "JuliaProject"
EOS
    ;;
"app")
    if [ "$w" != "" ]; then
        docker-compose exec -w "$w" app "${@:2:($#-1)}"
    else
        docker-compose exec app "${@:2:($#-1)}"
    fi
    ;;
*)
    docker-compose $*
    ;;
esac
