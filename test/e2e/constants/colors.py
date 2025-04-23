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
    GRAY = '#939ba1'
    INACTIVE_GRAY = '#7f8990'


class UserPictureColors:
    # ui/StatusQ/src/StatusQ/Core/Theme/StatusLightTheme.qml
    @staticmethod
    def profile_colors():
        return [
            "#2946C4",
            "#887AF9",
            "#51D0F0",
            "#D37EF4",
            "#FA6565",
            "#FFCA0F",
            "#7CDA00",
            "#26A69A",
            "#8B3131",
            "#9B832F",
            "#C0C0C0",
            "#A9A9A9"

        ]


class WalletAccountColors:
    # ui/StatusQ/src/StatusQ/Core/Theme/StatusLightTheme.qml
    @staticmethod
    def wallet_account_colors():
        return [
            "#2A4AF5",
            "#7140FD",
            "#FF7D46",
            "#216266",
            "#2A799B",
            "#1992D7",
            "#F6AF3C",
            "#F66F8F",
            "#CB6256",
            "#C78F67",
            "#EC266C",
            "#09101C"
        ]
