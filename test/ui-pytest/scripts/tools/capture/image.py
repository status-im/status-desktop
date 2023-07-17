import logging
import time
from datetime import datetime

import cv2
import numpy as np
import pytesseract
import typing
from PIL import ImageGrab

import configs
import driver
from scripts.tools.capture.ocv import Ocv
from scripts.utils.system_path import SystemPath

_logger = logging.getLogger(__name__)


class Image:

    def __init__(self, object_name: dict):
        self.object_name = object_name
        self._view = None

    @property
    def view(self):
        return self._view

    @property
    def height(self) -> int:
        return self.view.shape[0]

    @property
    def width(self) -> int:
        return self.view.shape[1]

    def update_view(self):
        _logger.info('Image view updated')
        rect = driver.object.globalBounds(driver.waitForObject(self.object_name))
        img = ImageGrab.grab(bbox=(rect.x, rect.y, rect.x + rect.width, rect.y + rect.height))
        self._view = cv2.cvtColor(np.array(img), cv2.COLOR_BGR2RGB)

    def save(self, path: SystemPath, force: bool = False):
        path.parent.mkdir(parents=True, exist_ok=True)
        if path.exists() and not force:
            raise FileExistsError(path)
        cv2.imwrite(str(path), self.view)

    def show(self):
        cv2.imshow('image', self.view)
        cv2.waitKey(0)
        cv2.destroyAllWindows()

    def compare(
            self, expected: typing.Union[SystemPath, 'Image'], threshold: float = 0.99, verify=True) -> bool:
        if isinstance(expected, SystemPath):
            expected = cv2.imread(str(expected))
        else:
            expected = expected.view
        correlation = Ocv.compare_images(self.view, expected)
        result = correlation >= threshold

        if verify:
            if result:
                _logger.info(f'Screenshot comparison passed (equality: {round(correlation, 4)})')
            else:
                configs.testpath.TEST_ARTIFACTS.mkdir(parents=True, exist_ok=True)
                diff = Ocv.draw_contours(self.view, expected)
                cv2.imwrite(str(configs.testpath.TEST_ARTIFACTS / f'diff_image.png'), diff)
                self.save(configs.testpath.TEST_ARTIFACTS / f'actual_image.png', force=True)
                cv2.imwrite(str(configs.testpath.TEST_ARTIFACTS / f'expected_image.png'), expected)

                _logger.info(
                    f"Screenshot comparison failed (equality: {round(correlation, 4)} %).\n"
                    f"Actual, Diff and Expected screenshots are saved:\n"
                    f"{configs.testpath.TEST_ARTIFACTS.relative_to(configs.testpath.ROOT)}.")
        return result

    def crop(self, rect: driver.UiTypes.ScreenRectangle):
        assert rect.x + rect.width < self.width
        assert rect.y + rect.height < self.height
        self._view = self.view[rect.y: (rect.y + rect.height), rect.x: (rect.x + rect.width)]

    def to_string(self, custom_config: str):
        text: str = pytesseract.image_to_string(self.view, config=custom_config)
        _logger.info(f'Text on image: {text}')
        return text

    def is_text_exists(self, text: str, criteria: str):
        self._view = cv2.cvtColor(self.view, cv2.COLOR_BGRA2GRAY)
        self.save(configs.testpath.TEST_ARTIFACTS / f'search_region_{datetime.now():%H%M%S_%f}.png', force=True)
        if text.lower() in self.to_string(criteria).lower():
            return True
        self._view = cv2.bitwise_not(self.view)
        self.save(configs.testpath.TEST_ARTIFACTS / f'search_region_{datetime.now():%H%M%S_%f}.png', force=True)
        if text.lower() in self.to_string(criteria).lower():
            return True
        return False


def compare(actual: Image,
            expected: typing.Union[SystemPath, Image],
            threshold: float = 0.99,
            timout_sec: int = 0
            ):
    start = datetime.now()
    while not actual.compare(expected, threshold):
        time.sleep(1)
        assert (datetime.now() - start).seconds > timout_sec, 'Comparison failed'
