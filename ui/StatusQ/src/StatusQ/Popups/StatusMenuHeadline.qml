import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

MenuSeparator {
    id: root

    property string text

    background: Rectangle {
        color: Theme.palette.statusMenu.backgroundColor
    }

    contentItem: StatusBaseText {
        color: Theme.palette.baseColor1
        font.pixelSize: Theme.tertiaryTextFontSize
        text: root.text
    }
}
