import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StyledText {
    property bool expanded: false
    property int maxWidth: 0
    property int oldWidth
    id: addressComponent
    text: "0x9ce0056c5fc6bb9459a4dcfa35eaad8c1fee5ce9"
    font.pixelSize: 13
    font.family: Theme.monoFont.name
    elide: Text.ElideMiddle
    color: Theme.palette.secondaryText

    StatusMouseArea {
        width: parent.width
        height: parent.height
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (addressComponent.expanded) {
                addressComponent.width = addressComponent.oldWidth
                this.width = addressComponent.width
            } else {
                addressComponent.oldWidth = addressComponent.width
                addressComponent.width = addressComponent.maxWidth > 0 ?
                            Math.min(addressComponent.implicitWidth, addressComponent.maxWidth) :
                            addressComponent.implicitWidth
                this.width = addressComponent.width
            }
            addressComponent.expanded = !addressComponent.expanded
        }
    }
}
