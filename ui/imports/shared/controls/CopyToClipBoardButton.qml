import QtQuick 2.13

import StatusQ.Controls 0.1

import utils 1.0

StatusRoundButton {
    id: copyToClipboardButton

    property var onClick: function() {}
    property string textToCopy: ""
    property bool tooltipUnder: false

    signal copyClicked(string textToCopy)

    icon.name: "copy"

    onPressed: {
        if (!toolTip.visible) {
            toolTip.visible = true
        }
    }
    onClicked: {
        if (textToCopy) {
            copyToClipboardButton.copyClicked(textToCopy)
        }
        onClick()
    }

    StatusToolTip {
        id: toolTip
        text: qsTr("Copied!")
        orientation: tooltipUnder ? StatusToolTip.Orientation.Bottom: StatusToolTip.Orientation.Top
        timeout: 2000
    }
}
