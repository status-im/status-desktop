import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

GridLayout {
    columns: 6
    columnSpacing: 5
    rowSpacing: 5

    Repeater {
        model: ["activity", "add-circle", "add-contact", "add",
            "address", "admin", "airdrop", "animals-and-nature",
            "browser", "arbitrator", "camera", "chat", "channel",
        "chatbot", "checkmark", "clear", "code", "communities"]

        delegate: StatusIcon {
            icon: modelData
            color: Theme.palette.primaryColor1
        }
    }
}
