import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

Column {
    spacing: 8

    Row {
        spacing: 4
        StatusWalletColorButton {
            icon.color: Theme.palette.miscColor1
            selected: true
        }
        StatusWalletColorButton {
            icon.color: Theme.palette.miscColor2
        }
        StatusWalletColorButton {
            icon.color: Theme.palette.miscColor3
        }
        StatusWalletColorButton {
            icon.color: Theme.palette.miscColor4
        }
        StatusWalletColorButton {
            icon.color: Theme.palette.miscColor5
        }
        StatusWalletColorButton {
            icon.color: Theme.palette.miscColor6
        }
        StatusWalletColorButton {
            icon.color: Theme.palette.miscColor7
        }
    }
}
