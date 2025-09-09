class Gestures:
    
    def __init__(self, driver):
        self._driver = driver

    def tap(self, x: int, y: int) -> bool:
        try:
            self._driver.execute_script("mobile: clickGesture", {"x": x, "y": y})
            return True
        except Exception:
            return False

    def long_press(self, element_id: str, duration_ms: int = 800) -> bool:
        try:
            self._driver.execute_script(
                "mobile: longClickGesture",
                {"elementId": element_id, "duration": duration_ms},
            )
            return True
        except Exception:
            return False

    def swipe_down(
        self, left: int, top: int, width: int, height: int, percent: float = 0.8
    ) -> bool:
        try:
            self._driver.execute_script(
                "mobile: swipeGesture",
                {
                    "left": left,
                    "top": top,
                    "width": width,
                    "height": height,
                    "direction": "down",
                    "percent": percent,
                },
            )
            return True
        except Exception:
            return False

    def swipe_up(
        self, left: int, top: int, width: int, height: int, percent: float = 0.8
    ) -> bool:
        try:
            self._driver.execute_script(
                "mobile: swipeGesture",
                {
                    "left": left,
                    "top": top,
                    "width": width,
                    "height": height,
                    "direction": "up",
                    "percent": percent,
                },
            )
            return True
        except Exception:
            return False

    def element_tap(self, element) -> bool:
        try:
            self._driver.execute_script(
                "mobile: clickGesture", {"elementId": element.id}
            )
            return True
        except Exception:
            return False

    def double_tap(self, x: int, y: int) -> bool:
        """Attempt a double-tap at coordinates; fallback to two single taps."""
        try:
            # Preferred: use count=2 if supported by the driver
            self._driver.execute_script(
                "mobile: clickGesture", {"x": x, "y": y, "count": 2}
            )
            return True
        except Exception:
            # Fallback: two rapid single taps
            try:
                self._driver.execute_script("mobile: clickGesture", {"x": x, "y": y})
                self._driver.execute_script("mobile: clickGesture", {"x": x, "y": y})
                return True
            except Exception:
                return False

    def element_double_tap(self, element) -> bool:
        """Attempt a double-tap on an element; fallback to two element taps."""
        try:
            self._driver.execute_script(
                "mobile: clickGesture", {"elementId": element.id, "count": 2}
            )
            return True
        except Exception:
            try:
                self._driver.execute_script(
                    "mobile: clickGesture", {"elementId": element.id}
                )
                self._driver.execute_script(
                    "mobile: clickGesture", {"elementId": element.id}
                )
                return True
            except Exception:
                return False
