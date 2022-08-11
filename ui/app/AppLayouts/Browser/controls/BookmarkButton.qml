import QtQuick 2.13

import StatusQ.Components 0.1 as StatusQ
import StatusQ.Core.Theme 0.1

import shared 1.0
import shared.panels 1.0
import shared.status 1.0

import utils 1.0

Item {
    property url webUrl
    property url source
    property string text
    signal clicked(mouse: var)
    signal rightClicked(mouse: var)

    id: root
    width: 74
    height: 48 + Style.current.halfPadding

    SVGImage {
        id: bookmarkImage
        width: 48
        height: 48
        anchors.horizontalCenter: parent.horizontalCenter
        source: !!root.source && !!root.source.toString() ? root.source : Style.svg("compassActive")
        visible: root.source && root.source.toString()
    }

    StatusQ.StatusRoundIcon {
        id: addButton
        anchors.horizontalCenter: parent.horizontalCenter
        asset.name: "add"
        asset.color: Theme.palette.baseColor1
        color: Theme.palette.baseColor2
        visible: !webUrl.toString()
    }

    StatusQ.StatusLetterIdenticon {
        id: identicon
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.palette.baseColor2
        identiconText.text: text.charAt(0)
        identiconText.color: Theme.palette.baseColor1
        visible: !bookmarkImage.visible && !addButton.visible
    }

    StyledText {
        id: bookmarkName
        text: root.text
        width: 67
        anchors.top: bookmarkImage.bottom
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Style.current.additionalTextSize
        wrapMode: Text.WordWrap
        anchors.topMargin: Style.current.halfPadding
        maximumLineCount: 2
        elide: Text.ElideRight
        textFormat: Text.PlainText
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (mouse.button === Qt.RightButton) {
                root.rightClicked(mouse)
            } else {
                root.clicked(mouse)
            }
        }
    }
}
