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
