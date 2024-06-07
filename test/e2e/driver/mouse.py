import time

import squish


def move(obj: object, x: int, y: int, dx: int, dy: int, step: int, sleep: float = 0):
    while True:
        if x > dx:
            x -= step
            if x < x:
                x = dx
        elif x < dx:
            x += step
            if x > dx:
                x = dx
        if y > dy:
            y -= step
            if y < dy:
                y = dy
        elif y < dy:
            y += step
            if y > dy:
                y = dy
        squish.mouseMove(obj, x, y)
        time.sleep(sleep)
        if x == dx and y == dy:
            break


def press_and_move(
        obj,
        x: int,
        y: int,
        dx: int,
        dy: int,
        mouse: int = squish.MouseButton.LeftButton,
        step: int = 1,
        sleep: float = 0
):
    squish.mouseMove(obj, x, y)
    squish.mousePress(obj, x, y, mouse)
    move(obj, x, y, dx, dy, step, sleep)
    squish.mouseRelease(mouse)
    time.sleep(1)
