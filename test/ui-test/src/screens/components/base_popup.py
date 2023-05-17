from drivers.SquishDriver import *


class BasePopup(BaseElement):

    def __init__(self):
        super(BasePopup, self).__init__('statusDesktop_mainWindow_overlay')

    def close(self):
        squish.nativeType('<Escape>')
        self.wait_until_hidden()
