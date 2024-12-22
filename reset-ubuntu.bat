@echo off

REM 使用法の表示
:usage
echo Usage: %0 [uninstall|install|start|stop|restart]
echo.
echo uninstall: Ubuntu 24.04 ディストリビューションの登録を解除します。
echo install  : Ubuntu 24.04 ディストリビューションを再インストールし、クラウド初期化のステータスを待機します。
echo start    : Ubuntu 24.04 を起動します。
echo stop     : Ubuntu 24.04 を終了します。
echo restart  : Ubuntu 24.04 を再起動します。
exit /b

REM Ubuntu 24.04 ディストリビューションの登録を解除
:uninstall
wsl --unregister Ubuntu-24.04 > nul 2>&1
exit /b

REM Ubuntu 24.04 ディストリビューションを再インストール（起動しない）
:install
wsl --install --distribution Ubuntu-24.04 --no-launch > nul 2>&1

REM ルートユーザーとして Ubuntu 24.04 をインストール
ubuntu2404.exe install --root

REM クラウド初期化のステータスを待機
ubuntu2404.exe run cloud-init status --wait
exit /b

REM Ubuntu 24.04 を起動
:start
ubuntu2404.exe
exit /b

REM Ubuntu 24.04 を終了
:stop
wsl -t Ubuntu-24.04
exit /b

REM Ubuntu 24.04 を再起動
:restart
call :stop
call :start
exit /b

REM コマンドライン引数の処理
set ACTION=%1

if "%ACTION%"=="uninstall" (
    call :uninstall
) else if "%ACTION%"=="install" (
    call :install
) else if "%ACTION%"=="start" (
    call :start
) else if "%ACTION%"=="stop" (
    call :stop
) else if "%ACTION%"=="restart" (
    call :restart
) else (
    call :usage
)