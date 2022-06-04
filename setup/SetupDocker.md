# Julia 1.6.1 on Docker

## Environment

- Shell: bash
- Docker: 20.10.2
    - docker-compose: 1.26.0

### Structure
```bash
./ # カレントディレクトリ = 作業ディレクトリ (docker://app:/work/)
|_ .env # 環境変数設定ファイル
|_ Dockerfile # appコンテナビルド設定
|_ docker-compose.yml # docker構成ファイル
|_ Manifest.toml # Juliaプロジェクト依存パッケージ設定ファイル
|_ Project.toml  # Juliaプロジェクト設定ファイル
|_ x # docker関連CLI
```

### Setup
```bash
# enable execution permission to cli interface
$ chmod +x ./x

# build all docker containers
$ ./x build

# execute all docker containers
$ ./x up -d

# appコンテナ起動確認
$ ./x logs -f app

# => 初回起動時は Julia パッケージのインストールに時間がかかる
# => JupyterLab の起動メッセージを確認できたら Ctrl + C で抜ける
```

### Docker containers
- networks:
    - **appnet**: All docker containers belong to this network.
- services:
    - **app**: `julia:1.6.1-buster`
        - Julia + JupyterLab server container.
        - routes:
            - HTTP(S): http://localhost:${JUPYTER_PORT:-8888} => http://app:8888
