# 機械学習環境構築

## Environment

### Windows
- OS: Windows 10
    - Shell: PowerShell
    - PackageManager: Chocolatey
- GPU: nVidia GeForce RTX 3070
    - CUDA Toolkit: `11.5.0`
    - cuDNN: `8.3.0`
- Editor: VSCode
- C++: Visual Studio 2019 Build Tools 
- pyenv-win: `2.64.11`
    - Python: `3.8.10`

### Linux (Ubuntu)
- OS: Ubuntu 20.04
    - Shell: bash
    - PackageManager: apt, linuxbrew
- Editor: VSCode
- anyenv: `1.1.4`
    - pyenv: `2.0.4`
        - Python:
            - 2系: `2.7.18`
            - 3系: `3.8.10`
                - ※ `--enable-shared` フラグを有効化してインストールすること

***

## Setup pyenv

### Setup on Windows 10
管理者権限 PowerShell で以下を実行

```powershell
# chocolateyパッケージマネージャを入れていない場合は導入する
> Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# C++ compiler インストール (ネットワーク環境にもよるが1時間程度かかる)
> choco install -y visualstudio2019buildtools --package-parameters "--add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --includeOptional --passive"

## => installed to C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools

# 一度 PC 再起動
> shutdown /r /t 0

# nVidia CUDA Toolkit インストール (GPUプログラミング用; ~2.5GB)
> choco install -y cuda

## => installed to C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.5

# cuDNN (CUDA 用ライブラリ) インストール
# - https://developer.nvidia.com/compute/machine-learning/cudnn/secure/8.3.0/11.5_20211101/cudnn-11.5-windows-x64-v8.3.0.98.zip からダウンロード
#     - ※ nVidia Developer 会員登録が必要
# - zip を解凍し、中の cuda ディレクトリを C:\ 直下に設置する
#     - => C:\cuda\
#              |_ bin\
#              |_ include\
#              |_ lib\
# - PATH を通す
> [System.Environment]::SetEnvironmentVariable("PATH", [System.Environment]::GetEnvironmentVariable("PATH", "User") + ";C:\cuda\bin", "User")

# pyenv-win インストール
> choco install -y pyenv-win

## => installed to ~/.pyenv

# => 環境変数反映のため一度 PowerShell 再起動

# pyenv バージョン確認
> pyenv --version
pyenv 2.64.11

# pyenv で python 3.8.10 をインストール
> pyenv install 3.8.10

# python: 3.8.11 に切り替え
> pyenv global 3.8.10
> pyenv rehash

# 確認
> pyenv versions
* 3.8.11 (set by %PYENV_VERSION%)

# pip パッケージマネージャを更新しておく
> pip install --user --upgrade pip setuptools

# Windows 10 環境では python (python3) コマンド実行時にストアアプリが開いてしまう
# => コマンドエイリアスを削除しておく
> rm ${env:USERPROFILE}\AppData\Local\Microsoft\WindowsApps\python.exe
> rm ${env:USERPROFILE}\AppData\Local\Microsoft\WindowsApps\python3.exe

# python バージョン確認
> python -V
```

### Setup on Ubuntu 20.04
```bash
# linuxbrew で anyenv 導入
$ brew install anyenv
$ anyenv install --init
## Do you want to checkout ? [y/N]: <= y

# anyenv 初期化スクリプトを .bashrc に記述
$ echo 'eval "$(anyenv init -)"' >> ~/.bashrc
$ source ~/.bashrc

# anyenv update plugin の導入
$ mkdir -p $(anyenv root)/plugins
$ git clone https://github.com/znz/anyenv-update.git $(anyenv root)/plugins/anyenv-update
$ anyenv update

# バージョン確認
$ anyenv -v
anyenv 1.1.1

# anyenv を使って pyenv 導入
## pyenv を使うことで、複数バージョンの Python 環境を構築できる
$ anyenv install pyenv
$ exec $SHELL -l

# pyenv で python 2.7.18, 3.8.10 をインストール
## python3 インストール時: --enable-shared オプションをつけないと PyCall.jl で libpython LoadError 等が発生する
$ pyenv install 2.7.18
$ env PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install 3.8.10

# python2: 2.7.18, python3: 3.8.10 に切り替え
$ pyenv global 2.7.18 3.8.10
$ exec $SHELL -l

# 確認
$ pyenv versions
  system
* 2.7.18 (set by /home/user/.anyenv/envs/pyenv/version)
* 3.8.10 (set by /home/user/.anyenv/envs/pyenv/version)

# pip パッケージマネージャを更新しておく
$ pip install --upgrade pip setuptools
$ pip3 install --upgrade pip setuptools
```

### Setup on macOS
```bash
# Homebrew で anyenv 導入
$ brew install anyenv
$ anyenv install --init

# anyenv 初期化スクリプトを .zshrc に記述
$ echo 'eval "$(anyenv init -)"' >> ~/.zshrc
$ source ~/.zshrc

# anyenv 更新
$ anyenv update

# anyenv を使って pyenv 導入
$ anyenv install pyenv
$ exec $SHELL -l

# python ビルドに必要なパッケージをインストール
$ brew install openssl
$ xcode-select --install

# pyenv で python 3.8.10 をインストール
## python3 インストール時: --enable-shared オプションをつけないと PyCall.jl で libpython LoadError 等が発生する
$ pyenv install 3.8.10
$ env PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install 3.8.10

# python 3.8.10 に切り替え
$ pyenv global 3.8.10
$ exec $SHELL -l

# 確認
$ pyenv versions
  system
* 3.8.10 (set by /home/user/.anyenv/envs/pyenv/version)

# pip パッケージマネージャを更新しておく
$ pip3 install --upgrade pip setuptools
```

***

## 機械学習環境構築

### JupterLab 環境構築
```bash
# JupyterLab, ipywidgets, JupyterConsole インストール
$ pip3 install jupyterlab ipywidgets jupyter-console

# pyenv を rehash して `jupyter` コマンドを使えるようにしておく
$ pyenv rehash

# JupyterLab 起動
## ブラウザで JupyterLab を使うより Jupyter in VSCode を使うほうが使いやすいかもしれない
# $ jupyter lab --port=8888 --ServerApp.token='' --project=@.

# JupyterConsole 起動
## ブラウザを立ち上げずにコンソール上で Jupyter を実行できる
# $ jupyter console --kernel=python3
```

### Jupyter 環境が壊れたとき（パスがおかしくなったりしたとき）
```bash
# 依存関係をまるごと削除する pip-autoremove パッケージをインストール
$ pip3 install pip-autoremove

# Jupyter 環境を依存関係ごと削除
$ pip-autoremove jupyterlab ipywidgets

# JupyterLab, ipywidgets を再インストール
$ pip3 install jupyterlab ipywidgets

# シェルを再起動
$ exec $SHELL -l
```

#### Jupyter in VSCode
- 以下の拡張機能をインストールする
    - [Jupyter](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter)
- `.ipynb` ファイルを VSCode で開くか、`Ctrl + Shift + P` |> `Jupyter: Create New Jupyter Notebook` コマンドで Jupyter Notebook を起動できる


### PyTorch 環境構築
ここでは PyTorch + OpenAI/CLIP 環境を構築する

https://github.com/openai/CLIP

```bash
# PyTorch 1.7.1 with CUDA 11.0, TorchVision インストール
$ pip install -f https://download.pytorch.org/whl/torch_stable.html torch==1.7.1+cu110 torchvision

# OpenAI/CLIP 関連モジュールインストール
$ pip install ftfy regex tqdm git+https://github.com/openai/CLIP.git

# PyTorch で GPU 利用可能か確認
$ python
>>> import torch
>>> torch.cuda.is_available()
True
>>> exit()
```

***

## Julia インストール

### Setup on Windows 10
```powershell
# Julia インストール
> choco install -y julia

# => 環境変数を反映するために一度 PowerShell 再起動

# Julia バージョン確認
> julia -v
julia version 1.7.2

# Julia REPL 起動
> julia

# PyCall.jl パッケージインストール
## PyCall.jl: Julia から Python を使うためのパッケージ
julia> using Pkg
julia> Pkg.add(PackageSpec(name="PyCall", rev="master"))

# pyenv で作成した python 3.8.10 環境と Julia を接続する
julia> ENV["PYTHON"] = ENV["USERPROFILE"] * raw"\.pyenv\pyenv-win\versions\3.8.10\python.exe"
julia> Pkg.build("PyCall")

# Julia と接続した Python 環境に JupyterLab + Julia Jupyter Kernel インストール
julia> using PyCall
julia> run(`$(PyCall.python) -m pip install jupyterlab ipywidgets`)
julia> Pkg.add(PackageSpec(name="IJulia", rev="master"))

# => Ctrl + D で終了

# Julia Jupyter Kernel がインストール済みか確認
> jupyter kernelspec list
  julia-1.7    C:\Users\user\AppData\Roaming\jupyter\kernels\julia-1.7
  python3      c:\users\user\.pyenv\pyenv-win\versions\3.8.10\share\jupyter\kernels\python3
```

### Setup on Ubuntu 20.04
```bash
# Julia インストール
$ wget -qO- https://julialang-s3.julialang.org/bin/linux/x64/1.7/julia-1.7.2-linux-x86_64.tar.gz | tar -xzv -C ~/
$ sudo ln -s ~/julia-1.7.2/julia /usr/local/bin/julia

# Julia バージョン確認
$ julia -v
julia version 1.7.2

# Julia REPL 起動
$ julia

# PyCall.jl パッケージインストール
## PyCall.jl: Julia から Python を使うためのパッケージ
### pyenv でインストールした python 3.8.10 環境と Julia を接続する
julia> using Pkg
julia> ENV["PYTHON"] = ENV["HOME"] * "/.anyenv/envs/pyenv/versions/3.8.10/python"
julia> Pkg.add(PackageSpec(name="PyCall", rev="master"))
julia> Pkg.build("PyCall")

# Julia と接続した Python 環境に JupyterLab + Julia Jupyter Kernel インストール
julia> using PyCall
julia> run(`$(PyCall.python) -m pip install jupyterlab ipywidgets`)
julia> Pkg.add(PackageSpec(name="IJulia", rev="master"))

# => Ctrl + D で終了

# Julia Jupyter Kernel がインストール済みか確認
$ jupyter kernelspec list
  julia-1.7    /home/user/.local/share/jupyter/kernels/julia-1.7
  python3      /home/user/.local/share/jupyter/kernels/python3
```

### Julia よく使うパッケージのインストール
- `HTTP.jl`: HTTP通信パッケージ
- `JSON.jl`: JSON読み込み・書き込みパッケージ
- `ProgressMeter.jl`: Jupyter環境でプログレスメータを表示するパッケージ
- `Pipe.jl`: パイプラインで部分評価をできるようにするパッケージ
- `Plots.jl`: データプロッティング用パッケージ
- `CSV.jl`: CSV読み込み・書き込みパッケージ
- `DataFrames.jl`: 行列データ操作パッケージ

```bash
# Pkg.add(["HTTP", "JSON", ...]) と書きたいが、PowerShell 環境では -e オプションの文字列周りにバグがあるため、
# Pkg.add([:HTTP, :JSON, ...] .|> string) と書いて、Vector{Symbol} |> Vector{String} の変換を挟んでいる
## https://github.com/julia-actions/setup-julia/issues/23
## ※ Windows 以外の環境であれば普通に Pkg.add(["HTTP", ...]) で良い

$ julia -e "using Pkg; Pkg.add([:HTTP, :JSON, :ProgressMeter, :Pipe, :Plots, :CSV, :DataFrames] .|> string)"
```

### Jupyter + Julia in VSCode
- 以下の拡張機能をインストールする
    - [Julia Insider](https://marketplace.visualstudio.com/items?itemName=julialang.language-julia-insider)
        - 普通の Julia Extension でも良いが、Julia Insider だと `\alpha` などの Unicode の TAB 補完が効く
- `.ipynb` ファイルを VSCode で開くか、`Ctrl + Shift + P` |> `Jupyter: Create New Jupyter Notebook` コマンドで Jupyter Notebook を起動
    - カーネルを Julia にすれば Jupyter + Julia in VSCode 環境でコーディングできる

***

## OpenAI/CLIP in Julia

[julia_CLIP.ipynb](../03_deep-learning/julia_CLIP.ipynb)
