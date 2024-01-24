from enum import Enum


class Color(Enum):
    WHITE = 1
    BLACK = 2
    RED = 3
    BLUE = 4
    GREEN = 5
    YELLOW = 6
    ORANGE = 7


boundaries = {
    Color.WHITE: [
        [0, 0, 0],
        [0, 0, 255]
    ],
    Color.BLACK: [
        [0, 0, 0],
        [179, 100, 130]
    ],
    Color.RED: [
        [
            [0, 100, 20],
            [10, 255, 255]
        ],
        [
            [160, 100, 20],
            [179, 255, 255]
        ]
    ],
    Color.BLUE: [
        [110, 50, 50],
        [130, 255, 255]
    ],
    Color.GREEN: [
        [36, 25, 25],
        [70, 255, 255]
    ],
    Color.YELLOW: [
        [20, 100, 0],
        [45, 255, 255]
    ],
    Color.ORANGE: [
        [10, 100, 20],
        [25, 255, 255]
    ]
}


class ColorCodes(Enum):
    GREEN = '#4ebc60'
    BLUE = '#2a4af5'
    ORANGE = '#ff9f0f'
