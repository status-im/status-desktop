import allure

from gui.components.os.open_file_dialogs import QrImageOpenFileDialog
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names
from scripts.utils.system_path import SystemPath


class QRCodeScannerPopup(QObject):

    def __init__(self):
        super().__init__(names.qrCodeScanner)
        self._upload_image_button = Button(names.qrUploadImageButton)

    @allure.step('Upload a QR image')
    def upload_image(self, fp: SystemPath) -> None:
        self._upload_image_button.click()
        QrImageOpenFileDialog().wait_until_appears().open_file(fp)
