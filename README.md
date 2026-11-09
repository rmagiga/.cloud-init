# WSL上のUbuntuをCloud-initで自動構築する

WSL (Windows Subsystem for Linux) 上の Ubuntu 環境を、**cloud-init** を用いて初期セットアップ（日本語化、ユーザー設定、GUI/日本語入力環境など）まで全自動で構築・再構築するスターターキットです。

> [!WARNING]
> **既存のWSL環境のリセットについて**  
> 本スクリプトを実行すると、同名の既存の WSL Ubuntu ディストリビューションは**完全に削除（初期化）**されます。必要なデータがある場合は、事前にバックアップを取ってから実行してください。

---

## ✨ 自動化される内容

本スクリプトを実行するだけで、以下のセットアップが完了した状態で立ち上がります。

- **OS・パッケージ**: パッケージリストの更新・最新化
- **日本語化**: タイムゾーン（`Asia/Tokyo`）およびロケール（`ja_JP.UTF-8`）の設定
- **ユーザー設定**: 一般ユーザー（`ubuntu`）およびグループの作成・sudo権限付与・デフォルトログイン設定
- **時刻同期**: 起動時の時刻合わせ設定
- **日本語入力・フォント**:
  - `fcitx5` + `fcitx5-mozc` のインストールと環境変数設定
  - 日本語フォント（`fonts-noto-cjk`）の追加
- **エラー抑制**:
  - `~/.hushlogin` によるログインメッセージの整理
  - GNOME系アプリ起動時の Mesa/GL 関連エラー抑制設定

---

## 📋 動作確認環境

- **OS**: Windows 11 (24H2 推奨)
- **WSL**: WSL 2 / WSLg 対応バージョン
  ```text
  WSL バージョン: 3.0.x 以上
  WSLg バージョン: 1.0.x 以上
  ```

---

## 🚀 クイックスタート

Windows の PowerShell または コマンドプロンプト を起動して実行します。

### 1. リポジトリのクローン
```bat
cd %USERPROFILE%
git clone https://github.com/rmagiga/wsl-ubuntu-starter-jp.git
cd wsl-ubuntu-starter-jp
```

### 2. 構築スクリプトの実行

利用したいバージョンに応じて、以下のいずれかのコマンドを実行します。

- **Ubuntu 24.04 LTS を構築する場合（デフォルト）**:
  ```bat
  .\reset-ubuntu.bat 24.04
  rem またはショートカット: .\reset-ubuntu2404.bat
  ```

- **Ubuntu 26.04 を構築する場合**:
  ```bat
  .\reset-ubuntu.bat 26.04
  rem またはショートカット: .\reset-ubuntu2604.bat
  ```

※ 実行後、WSLの登録解除 → 新規インストール → cloud-init によるプロビジョニングが自動で行われ、完了すると自動的にログインされます。

---

## 🛠️ 構築後の初期設定・確認

構築完了後、WSL（Ubuntu）ターミナル内で以下の設定・確認を行います。

### 1. 日本語入力（fcitx5）の初期設定
GUI 設定ツールを起動して、入力メソッドの並びを整えます。

```bash
fcitx5-configtool
```
1. 設定画面が開いたら、「現在の入力メソッド」一覧を確認します。
2. もし `キーボード - 英語 (US)` が不要な場合は選択して削除（`>` ボタン）し、`キーボード - 日本語` と `Mozc` が含まれるようにします。
3. 「適用」または「OK」をクリックして保存します。

### 2. GUI アプリ（WSLg）の動作確認
GNOME テキストエディタをインストールして起動テストを行います。

```bash
sudo apt install -y gnome-text-editor
gnome-text-editor
```
- エディタが立ち上がったら、`Ctrl + Space`（または半角/全角キー）で日本語入力ができるか確認してください。

> [!NOTE]
> メニューを日本語化したい場合は追加パッケージをインストールできますが、初回起動に少し時間がかかる場合があります。
> ```bash
> sudo apt install -y task-japanese-gnome-desktop language-pack-gnome-ja
> ```

### 3. [Tips] Windows側の `.gitconfig` を共有する
Windows 側で設定済みの Git 設定を WSL 側でもそのまま使いたい場合は、シンボリックリンクを作成します。

```bash
ln -s "/mnt/c/Users/$(whoami.exe | tr -d '\r' | awk -F'\\' '{print $2}')/.gitconfig" ~/.gitconfig
```

---

## 📂 ファイル構成

```text
wsl-ubuntu-starter-jp
  ├── README.md               # 本ドキュメント
  ├── reset-ubuntu.bat        # 自動構築のメインスクリプト（引数: バージョン）
  ├── reset-ubuntu2404.bat    # 24.04 構築用ショートカット
  ├── reset-ubuntu2604.bat    # 26.04 構築用ショートカット
  ├── Ubuntu-24.04.user-data  # 24.04 用 cloud-init 定義ファイル
  └── Ubuntu-26.04.user-data  # 26.04 用 cloud-init 定義ファイル
```

---

## 🔍 技術詳細 & カスタマイズ

本環境では、クラウドインスタンスの初期化標準である **cloud-init** を WSL の `/etc/cloud/cloud.cfg.d/` に流し込み、systemd 経由で初回起動時に一括適用しています。

### `*.user-data` の主な定義内容
- `apt`: ミラーリポジトリの設定
- `timezone` / `locale`: 日本時間・日本語化
- `package_update` / `package_upgrade`: パッケージ最新化
- `users` / `groups`: ユーザー `ubuntu` (UID 1000) の追加と sudo 権限付与
- `packages`: `fcitx5`, `fonts-noto-cjk`, 各種ビルドツールの導入
- `write_files`: 環境変数 (`/etc/environment.d/`) や `.hushlogin` の配置
- `runcmd`: 起動直後のワンショットコマンド実行

### トラブルシューティング & 設定のポイント
- **ログインメッセージの抑制**:  
  `~/.hushlogin` を作成することで、Ubuntu ログイン時に表示される長文バナーを非表示にしています。
- **Mesa 3D レンダリングエラー対応**:  
  WSLg 上で GNOME アプリを起動する際に発生しやすい GL/Zink 関連のエラーを回避するため、環境変数 `LIBGL_ALWAYS_SOFTWARE=1` を設定しています。
