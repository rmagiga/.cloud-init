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


sudo apt install -y fcitx5-mozc

export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5
export XMODIFIERS=@im=fcitx5
export INPUT_METHOD=fcitx5
export DefaultIMModule=fcitx5
if [ $SHLVL = 1 ] ; then
  (fcitx5 --disable=wayland -d --verbose '*'=0 &)
fi

sudo apt install -y gnome-text-editor


```
MESA: error: ZINK: failed to choose pdev
libEGL warning: egl: failed to create dri2 screen
MESA: error: ZINK: failed to choose pdev
glx: failed to create drisw screen

(gnome-text-editor:520): GLib-GIO-CRITICAL **: 22:31:27.187: g_file_new_for_path: assertion 'path != NULL' failed

(gnome-text-editor:520): editor-document-WARNING **: 22:31:27.187: Your system has an improperly configured XDG_DOCUMENTS_DIR. Using $HOME instead.
```

sudo apt install mesa-utils

export LIBGL_ALWAYS_SOFTWARE=1