import cv2
import numpy as np


class Ocv:

    @classmethod
    def compare_images(cls, lhd: np.ndarray, rhd: np.ndarray) -> float:
        res = cv2.matchTemplate(lhd, rhd, cv2.TM_CCOEFF_NORMED)
        _, correlation, _, _ = cv2.minMaxLoc(res)
        return correlation

    @classmethod
    def draw_contours(cls, lhd: np.ndarray, rhd: np.ndarray) -> np.ndarray:
        view = rhd.copy()

        lhd = cv2.cvtColor(lhd, cv2.COLOR_BGRA2GRAY)
        _, thresh = cv2.threshold(lhd, 0, 255, cv2.THRESH_BINARY_INV | cv2.THRESH_OTSU)
        contours, hierarchy = cv2.findContours(thresh, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
        cv2.drawContours(view, contours, -1, (0, 0, 255), 1)

        rhd = cv2.cvtColor(rhd, cv2.COLOR_BGRA2GRAY)
        _, thresh = cv2.threshold(rhd, 0, 255, cv2.THRESH_BINARY_INV | cv2.THRESH_OTSU)
        contours, hierarchy = cv2.findContours(thresh, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
        cv2.drawContours(view, contours, -1, (0, 255, 0), 1)

        return view
