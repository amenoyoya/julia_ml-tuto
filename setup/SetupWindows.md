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
> choco install -y julia

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
## * 合わせて nodejs と ipywidgets もインストールしておくと Jupyter 上で Rich UI を使えるようになる
# $ conda install -y -c conda-forge jupyterlab nodejs ipywidgets
julia> using Conda
julia> Conda.add(["jupyterlab", "nodejs", "ipywidgets"]; channel="conda-forge")

# JupyterLab で Julia カーネルを使えるようにするため IJulia パッケージインストール
julia> ]
pkg> add IJulia
pkg> ^C

# 一旦 Julia REPL 終了
julia> exit()

# ユーザ環境変数 PATH に Anaconda in Julia の PATH 追加
> [System.Environment]::SetEnvironmentVariable("PATH", [System.Environment]::GetEnvironmentVariable("PATH", "User") + ";${ENV:USERPROFILE}\.julia\conda\3\Scripts;${ENV:USERPROFILE}\.julia\conda\3\Library\bin", "User")
> [System.Environment]::SetEnvironmentVariable("JUPYTER_PATH", "${ENV:USERPROFILE}\.julia\conda\3\share\jupyter", "User")

# PowerShell起動時に Anaconda をアクティベーションするために
## PowerShell script (.ps1) を実行可能できるようにポリシー変更
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

# PowerShell起動時に Anaconda をアクティベーションするプロファイル作成
> New-Item -ItemType Directory "$env:USERPROFILE\Documents\WindowsPowerShell"

> echo "(& `"$env:USERPROFILE\.julia`\conda\3\Scripts\conda.exe`" `"shell.powershell`" `"hook`") | Out-String | Invoke-Expression" | Out-File -Append -Encoding utf8 -FilePath "$env:USERPROFILE\Documents\WindowsPowerShell\profile.ps1"

# => 環境変数反映・プロファイル読み込みのため一度 PowerShell 再起動

# Jupyter カーネル確認
> jupyter kernelspec list
Available kernels:
  julia-1.6    C:\Users\<ユーザ名>\AppData\Roaming\jupyter\kernels\julia-1.6 # <= IJulia
  python3      C:\Users\<ユーザ名>\.julia\conda\3\share\jupyter\kernels\python3

# JupyterLab ipywidgets 拡張機能をインストール
> jupyter labextension install "@jupyter-widgets/jupyterlab-manager"

# Juliaチュートリアルプロジェクトディレクトリ作成・移動
> New-Item -ItemType Directory ~\julia-tuto
> cd ~\julia-tuto\

# Manifest.toml, Project.toml 作成
> New-Item Manifest.toml
> echo 'name = "JuliaTutorial"' | Out-File Project.toml

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
