# Julia 1.6.1 on Windows 10

## Environment

- OS: Windows 10
- GPU: nVidia RTX 2060
- Shell: PowerShell
- PackageManager: Chocolatey 0.10.15
- Julia: 1.6.1
    - Anaconda: 1.5.2
        - JupyterLab: 3.0.15

### Setup
`Win + X` |> `A` => 管理者権限 PowerShell 起動

```powershell
# chocolateyパッケージマネージャを入れていない場合は導入する
> Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Julia インストール
> conda install -c conda-forge julia

# => 環境変数を反映するために一度 PowerShell 再起動

# Julia バージョン確認
> julia -v
julia version 1.6.1

# Julia REPL 起動
> julia

# PyCall.jl, Conda.jl パッケージインストール
## PyCall.jl: Julia から Python を使うためのパッケージ
## Conda.jl: Anaconda python 環境を Julia 内に作成するパッケージ
## * PyCall をインストールすれば Conda は自動的に入る

# `]` キーでパッケージモードに切り替え
julia> ]

pkg> add PyCall
pkg> add Conda

# Ctrl + C => パッケージモード終了
pkg> ^C

# Conda.jl で JupyterLab インストール
## JupyterLab: Jupyter Notebook の後継
## * Jupyter Notebook: ノートブック形式でデータを可視化しながらプログラミング言語（主にPython）を実行できるIDE環境
# $ conda install -y -c conda-forge jupyterlab
julia> using Conda
julia> Conda.add("jupyterlab"; channel="conda-forge")

# JupyterLab で Julia カーネルを使えるようにするため IJulia パッケージインストール
julia> ]
pkg> add IJulia
pkg> ^C

# 一旦 Julia REPL 終了
julia> exit()

# ユーザ環境変数 PATH に Anaconda in Julia の PATH 追加
> [System.Environment]::SetEnvironmentVariable("PATH", [System.Environment]::GetEnvironmentVariable("PATH", "User") + ";${ENV:USERPROFILE}\.julia\conda\3\Scripts;${ENV:USERPROFILE}\.julia\conda\3\Library\bin", "User")

# => 環境変数を反映するために一度 PowerShell 再起動

# Jupyter カーネル確認
> jupyter kernelspec list
Available kernels:
  julia-1.6    C:\Users\<ユーザ名>\AppData\Roaming\jupyter\kernels\julia-1.6 # <= IJulia
  python3      C:\Users\<ユーザ名>\.julia\conda\3\share\jupyter\kernels\python3

# JupyterLab 起動
## * 実行ポート: 8888
## * token不要
## * Project.toml へのパス: ./
###  + --project=<Project.tomlへのパス> を指定することで対応する仮想環境で作業できるようになる
###  + 指定しない場合、デフォルトのグローバル環境で作業することになるため、環境を汚してしまうデメリットがある
> jupyter lab --port=8888 --ServerApp.token='' --project=@.

# => http://localhost:8888/lab で JupyterLab が開く
```

![jupyterlab.png](./img/jupyterlab.png)

Juliaのプログラムを実行できるノートを新規作成するためには `+` > `Notbook` > `Julia 1.6.1` を選択する 
