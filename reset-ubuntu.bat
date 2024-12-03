@echo off

wsl --unregister Ubuntu-24.04 > nul 2>&1
wsl --install --distribution Ubuntu-24.04 --no-launch > nul 2>&1
ubuntu2404.exe install --root
ubuntu2404.exe run cloud-init status --wait

wsl -t Ubuntu-24.04
rem wsl -d Ubuntu-24.04
ubuntu2404.exe