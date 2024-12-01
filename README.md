wsl --install --distribution Ubuntu-24.04 --no-launch
# ubuntuを初期化する。必ずrootユーザーで行う。
ubuntu2404.exe install --root
# --format jsonオプションはつけてはならない。
ubuntu2404.exe run cloud-init status --wait

# 登録解除
wsl --unregister Ubuntu-24.04


# 読み込まれたYAMLの内容は以下のコマンド
sudo cloud-init query userdata

# 表示される内容が有効であるかはこの出力からは分からないので、以下のコマンドで確認します。
sudo cloud-init schema --system --annotate


systemctl list-unit-files --type=service


    command=hwclock -s

http://verifiedby.me/adiary/0185
