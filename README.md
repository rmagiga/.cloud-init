# WSL上のUbuntu 24.04をCloud-initで自動構築する

## 概要

このプロジェクトは、WSLにUbuntu 24.04をインストールして、できるだけ設定を自動化させることが目的です。  
実行することで、ユーザー・グループ追加、タイムゾーン、ロケール、
WSLgによって、Linux GUIアプリケーションを実行できるようになります。  
構築は、cloud-initで行います。

## 環境

- Windows 11 24H2

WSLのバージョン(2024/12/05時点)
```
>wsl --version
WSL バージョン: 2.3.26.0
カーネル バージョン: 5.15.167.4-1
WSLg バージョン: 1.0.65
MSRDC バージョン: 1.2.5620
Direct3D バージョン: 1.611.1-81528511
DXCore バージョン: 10.0.26100.1-240331-1435.ge-release
Windows バージョン: 10.0.26100.2454
```

## 自動化する内容

- パッケージの最新化
- タイムゾーン、ロケールを日本へ
- ユーザー(ubuntu)、グループ(wsl-users)の追加と設定(uid: 1000、gid: 1000)、デフォルトユーザー設定
- 起動時の時刻あわせ設定
- インプットメソッドのインストールと一部設定(fcitx5とmozc)
- Notoフォント追加
- ログイン、および、gnome-text-editoのエラー抑制

## ファイル

```
.cloud-init
  |-  README.md
  |-  reset-ubuntu.bat
  |-  Ubuntu-24.04.user-data
```

- reset-ubuntu.bat
  - Ubuntu 24.04の自動構築プログラム
  - WSLにUbuntu 24.04の登録と解除、自動構築
- Ubuntu-24.04.user-data
  - cloud-initのユーザーデータ
  - cloud-initで自動構築するための設定ファイル

## 実行方法

```
> cd %USERPROFILE%
> git clone https://github.com/rmagiga/.cloud-init.git
> cd .cloud-init
> .\reset-ubuntu.bat
```

## 詳細

構築は、cloud-initで行います。
cloud-initは、クロスプラットフォームのクラウドインスタンスの初期化のためのツールです。  
もともとは、AWSのEC2の初期化のために作られたそうですが、クラウド全般に使えるようになり、今回は、WSLでの自動構築に使用します。
systemd上で、初回起動時の1回のみ実行されます。

内容については、[cloud-initドキュメント](https://cloudinit.readthedocs.io/en/latest/index.html) を参照してください。

### Ubuntu-24.04.user-data

- api
  - パッケージのリポジトリを設定します。
- timezone
  - タイムゾーンの設定
- locale
  - ロケールの設定
- package_update と package_upgrade
  - パッケージの最新化
- groups
  - グループの追加
- users
  - ユーザーの追加
- package
  - 追加パッケージ
- write_files
  - ファイル操作
- keyboard
  - キーボード設定
- runcmd
  - 構築後のコマンド実行


#### ログインエラーの抑制
```
- path: /home/ubuntu/.hushlogin
  content: ""
  owner: ubuntu:ubuntu
  permissions: '0644'
  defer: true
```

#### gnome text editorの起動時に出るエラー対応

エラー内容
```
MESA: error: ZINK: failed to choose pdev
libEGL warning: egl: failed to create dri2 screen
MESA: error: ZINK: failed to choose pdev
glx: failed to create drisw screen

(gnome-text-editor:520): GLib-GIO-CRITICAL **: 22:31:27.187: g_file_new_for_path: assertion 'path != NULL' failed

(gnome-text-editor:520): editor-document-WARNING **: 22:31:27.187: Your system has an improperly configured XDG_DOCUMENTS_DIR. Using $HOME instead.
```

対応：Mesa 3Dのlibglをソフトウェアレンダリングに設定
```
export LIBGL_ALWAYS_SOFTWARE=1
```

### reset-ubuntu.bat

WSL上のUbuntu 24.04の操作をします。

- Ubuntu 24.04をアンインストール
- Ubuntu 24.04をログインせずに、インストール
- Ubuntu 24.04をrootで起動して、cloud-initの実行
- cloud-initの実行を待機
- Ubuntu 24.04のシャットダウン
- Ubuntu 24.04へログイン

## WSLgの確認

### インプットメソッドの設定

fcitx5の設定は、GUIから行ったほうが、簡単なので、それを行います。
> 行わなくても、Mozcの設定がされていないだけなので、使用は可能です。

fcitx5-configtoolを実行します。
```sh
fcitx5-configtool
```
実行すると、Fcitxの設定が可能になります。
現在の入力メソッドで、「キーボード-英語(US)」があるので、選択して、削除(→のアイコンを選択)します。
OKボタンを押下して、保存します。

保存すると、「~/.config/」配下に、fcitx5の設定が追加されます。

### エディタ

GNOME標準のGnome Text Editorを使ってみます。
エディタを起動して、Ctrl + Spaceで半角/全角の変換をします。

エディタのインストールシェル
```sh
sudo apt install -y gnome-text-editor
```

起動コマンド
```sh
gnome-text-editor
```

メニューの日本語化をする場合は、以下のようにインストールしてください。  
> ただし、実行すると、エディタの起動が遅くなり、1,2分ぐらい待つことになります。
> インストールしなくても動くので(英語メニュー)、確認だけなら実行しなくてOKです。
```sh
sudo apt install -y task-japanese-gnome-desktop language-pack-gnome-ja-base language-pack-gnome-ja gnome-user-docs-ja
```

### Git設定の共通化

Windows11とWSLの.gitconfigを共通に使用する。
WSL上のUbuntuから実行します。

```
ln -s /mnt/c/Users/$(whoami.exe | awk -F'\' '{print $2}')/.gitconfig ~/.gitconfig
```

解説
Windowsの実行ユーザーをwhoami.exeから取得して加工します。そのディレクトリパスを使って、シンボリックリンクを張り、設定を共通化できます。
