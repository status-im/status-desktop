from gui.elements.qt.object import QObject


class BackUpSeedPhraseBanner(QObject):
    def __init__(self):
        super(BackUpSeedPhraseBanner, self).__init__('mainWindow_secureYourSeedPhraseBanner_ModuleWarning')
