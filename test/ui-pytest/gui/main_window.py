import logging

from gui.elements.qt.window import Window

_logger = logging.getLogger(__name__)


class MainWindow(Window):

    def __init__(self):
        super(MainWindow, self).__init__('statusDesktop_mainWindow')
