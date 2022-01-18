import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import Sandbox 0.1

Column {
    spacing: 8

    StatusChatCommandButton {
        icon.name: "send"
        icon.color: Theme.palette.miscColor2
        text: "Send transaction"
    }

    StatusChatCommandButton {
        icon.name: "send"
        icon.rotation: 180
        icon.color: Theme.palette.miscColor8
        text: "Receive transaction"
    }
}
