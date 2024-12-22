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
echo uninstall: Ubuntu 24.04 �f�B�X�g���r���[�V�����̓o�^���������܂��B
echo install  : Ubuntu 24.04 �f�B�X�g���r���[�V�������ăC���X�g�[�����A�N���E�h�������̃X�e�[�^�X��ҋ@���܂��B
echo start    : WSL��Ubuntu 24.04 �����s���܂��B
echo stop     : Ubuntu 24.04 ���I�����܂��B
echo reset    : Ubuntu 24.04 �������E�o�^�E�ċN�����܂��B
exit /b


:reset
call :stop
call :start
exit /b

REM Ubuntu 24.04 �f�B�X�g���r���[�V�����̓o�^������
:uninstall
wsl --unregister Ubuntu-24.04 > nul 2>&1
exit /b

REM Ubuntu 24.04 �f�B�X�g���r���[�V�������ăC���X�g�[���i�N�����Ȃ��j
:install
wsl --install --distribution Ubuntu-24.04 --no-launch > nul 2>&1

REM ���[�g���[�U�[�Ƃ��� Ubuntu 24.04 ���C���X�g�[��
ubuntu2404.exe install --root

REM �N���E�h�������̃X�e�[�^�X��ҋ@
ubuntu2404.exe run cloud-init status --wait
exit /b

REM WSL Ubuntu 24.04 �����s
:start
rem ubuntu2404.exe
wsl -d Ubuntu-24.04
exit /b

REM Ubuntu 24.04 ���I��
:stop
wsl -t Ubuntu-24.04
exit /b

:eof