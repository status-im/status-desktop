import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

ColumnLayout {
    spacing: 8

    StatusBaseText {
        text: qsTr("Uniswap Interface will be able to:")

        font.pixelSize: 13
        color: Theme.palette.baseColor1
    }

    StatusBaseText {
        text: qsTr("Check your account balance and activity")

        font.pixelSize: 13
    }

    StatusBaseText {
        text: qsTr("Request transactions and message signing")

        font.pixelSize: 13
    }
}
