import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

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
