import configs

if configs.system.IS_WIN:
    from .win.open_file_dialogs import OpenFileDialog as BaseOpenFileDialog
elif configs.system.IS_MAC:
    from .mac.open_file_dialogs import OpenFileDialog as BaseOpenFileDialog
else:
    from .lin.open_file_dialog import OpenFileDialog as BaseOpenFileDialog


class OpenFileDialog(BaseOpenFileDialog):
    pass
