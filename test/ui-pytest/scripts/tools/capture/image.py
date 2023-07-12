import logging
import time
from datetime import datetime

import cv2
import numpy as np
from PIL import ImageGrab

import configs
import driver
from scripts.tools.capture.ocv import Ocv
from scripts.utils.system_path import SystemPath

_logger = logging.getLogger(__name__)


class Image:

    def __init__(self, object_name: dict):
        self.object_name = object_name

    @property
    def view(self) -> np.ndarray:
        rect = driver.object.globalBounds(driver.waitForObject(self.object_name))
        img = ImageGrab.grab(bbox=(rect.x, rect.y, rect.x + rect.width, rect.y + rect.height))
        return cv2.cvtColor(np.array(img), cv2.COLOR_BGR2RGB)

    @property
    def height(self) -> int:
        return self.view.shape[0]

    @property
    def width(self) -> int:
        return self.view.shape[1]

    def save(self, path: SystemPath, force: bool = False):
        path.parent.mkdir(parents=True, exist_ok=True)
        if path.exists() and not force:
            raise FileExistsError(path)
        cv2.imwrite(str(path), self.view)

    def show(self):
        cv2.imshow('image', self.view)
        cv2.waitKey(0)
        cv2.destroyAllWindows()

    def compare(self, fp: SystemPath, threshold: float = 0.99, verify=True) -> bool:
        expected_view = cv2.imread(str(fp))
        correlation = Ocv.compare_images(self.view, expected_view)
        result = correlation >= threshold

        if verify:
            if result:
                _logger.info(
                    '{file}: Screenshot comparison passed (equality: {diff})'.format(
                        file=fp.name, diff=round(correlation, 4))
                )
            else:
                configs.testpath.TEST_ARTIFACTS.mkdir(parents=True, exist_ok=True)
                diff = Image(Ocv.draw_contours(self.view, expected_view))
                diff.save(configs.testpath.TEST_ARTIFACTS / f'diff_{fp.name}', force=True)
                self.save(configs.testpath.TEST_ARTIFACTS / f'actual_{fp.name}', force=True)

                _logger.info(
                    f"{fp.name}:\nScreenshot comparison failed (equality: {round(correlation, 4)} %).\n"
                    f"Actual and Diff screenshots are saved:\n"
                    f"{configs.testpath.TEST_ARTIFACTS.relative_to(configs.testpath.ROOT)}.")
        return result


def compare(actual: Image,
            expected: SystemPath,
            threshold: float = 0.99,
            timout_sec: int = 0
            ):
    start = datetime.now()
    while not actual.compare(expected, threshold):
        time.sleep(1)
        assert (datetime.now() - start).seconds > timout_sec, 'Comparison failed'
