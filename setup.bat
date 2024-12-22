@echo off

set ACTION="%1"

if %ACTION%=="" (
  set ACTION="reset"
)

if %ACTION%=="uninstall" (
  call :uninstall
) else if %ACTION%=="install" (
  call :install
) else if %ACTION%=="start" (
  call :start
) else if %ACTION%=="stop" (
  call :stop
) else if %ACTION%=="reset" (
  call :reset
) else (
  call :usage
)

goto :eof

:usage
echo "Usage: %~nx0 [uninstall|install|start|stop|restart]"
echo.
echo uninstall: Ubuntu 24.04 ディストリビューションの登録を解除します。
echo install  : Ubuntu 24.04 ディストリビューションを再インストールし、クラウド初期化のステータスを待機します。
echo start    : WSLのUbuntu 24.04 を実行します。
echo stop     : Ubuntu 24.04 を終了します。
echo reset    : Ubuntu 24.04 を解除・登録・再起動します。
exit /b


:reset
call :stop
call :start
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

REM WSL Ubuntu 24.04 を実行
:start
rem ubuntu2404.exe
wsl -d Ubuntu-24.04
exit /b

REM Ubuntu 24.04 を終了
:stop
wsl -t Ubuntu-24.04
exit /b

:eof