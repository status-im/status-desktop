import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import Sandbox 0.1
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
