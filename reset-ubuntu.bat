@echo off
setlocal

:: バージョン番号の引数チェック（未指定時は 24.04 をデフォルトとする）
set "VER=%~1"
if "%VER%"=="" set "VER=24.04"

set "DISTRO=Ubuntu-%VER%"
set "USER_DATA=%~dp0%DISTRO%.user-data"
set "LOG_FILE=%TEMP%\wsl-reset-%DISTRO%.log"

echo ============================================================
echo  WSL %DISTRO% のリセット処理を開始します
echo ============================================================

:: 0. 事前チェック: user-data の存在確認
if not exist "%USER_DATA%" (
    echo [ERROR] user-data ファイルが見つかりません: "%USER_DATA%"
    goto :ON_ERROR
)

:: 1. %USERPROFILE%\.cloud-init ディレクトリの確認・作成
echo [1/6] 設定ディレクトリを確認中...
if not exist "%USERPROFILE%\.cloud-init" (
    mkdir "%USERPROFILE%\.cloud-init" 2> "%LOG_FILE%"
    if errorlevel 1 (
        echo [ERROR] ディレクトリの作成に失敗しました: %USERPROFILE%\.cloud-init
        goto :SHOW_LOG_AND_ERROR
    )
)

:: 2. user-data ファイルの配置
echo [2/6] cloud-init 設定ファイル（%DISTRO%.user-data）を配置中...
copy /y "%USER_DATA%" "%USERPROFILE%\.cloud-init\" > nul 2> "%LOG_FILE%"
if errorlevel 1 (
    echo [ERROR] user-data ファイルのコピーに失敗しました。
    goto :SHOW_LOG_AND_ERROR
)

:: 3. 既存環境の登録解除（未インストール時は失敗しても問題ないため無視）
echo [3/6] 既存の %DISTRO% を登録解除（削除）中...
wsl --unregister %DISTRO% > nul 2>&1

:: 4. ディストリビューションの新規インストール
echo [4/6] %DISTRO% をインストール中（初回ダウンロード時は時間がかかります）...
wsl --install --distribution %DISTRO% --no-launch > "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [ERROR] WSL ディストリビューションのインストールに失敗しました。
    goto :SHOW_LOG_AND_ERROR
)

:: 5. cloud-init の完了待機
echo [5/6] cloud-init のプロビジョニング完了を待機中...
wsl -d %DISTRO% -u root -- cloud-init status --wait
if errorlevel 1 (
    echo.
    echo [ERROR] cloud-init の処理中にエラーが発生しました。
    echo 以下のコマンドで詳細ログを確認できます:
    echo   wsl -d %DISTRO% -u root -- cat /var/log/cloud-init-output.log
    goto :ON_ERROR
)

:: 6. インスタンスの再起動と接続
echo [6/6] %DISTRO% を再起動してログインします...
wsl -t %DISTRO%
echo ============================================================
echo  セットアップが完了しました。シェルを起動します。
echo ============================================================

:: 正常終了時は一時ログを削除
if exist "%LOG_FILE%" del "%LOG_FILE%"

wsl -d %DISTRO%
goto :EOF

:: --- エラー処理ルーチン ---
:SHOW_LOG_AND_ERROR
echo.
echo --- エラー詳細ログ (%LOG_FILE%) ---
if exist "%LOG_FILE%" type "%LOG_FILE%"
echo ---------------------------------------

:ON_ERROR
echo.
echo ============================================================
echo [FAILED] 処理が途中で失敗したため中断しました。
echo ============================================================
pause
exit /b 1
