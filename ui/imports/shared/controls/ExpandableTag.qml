import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Control {
    id: root
    width: 120
    height: 50
    anchors.left: parent.left
    anchors.leftMargin: 12
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 12

    property string tagHeaderText
    property string tagName
    property string tagImage
    property color backgroundColor: Theme.palette.baseColor4

    signal tagClicked()

    contentItem: Item {

        StatusBaseText {
            id: textLabel
            width:  parent.width
            visible: hovered && !!root.tagHeaderText
            opacity: visible ? 1 : 0
            color: Theme.palette.indirectColor1
            Behavior on opacity { NumberAnimation {} }
            verticalAlignment: Text.AlignVCenter
            text: root.tagHeaderText
            elide: Text.ElideRight
            font.weight: Font.Medium
        }
        Rectangle {
            id: tagBackground
            width: (tagImage.width+tagName.width)
            Behavior on width { NumberAnimation {} }
            height: 24
            anchors.top: textLabel.bottom
            anchors.topMargin: 4
            radius: parent.width/2
            color: root.backgroundColor
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: hovered ? Qt.PointingHandCursor : undefined
                onClicked: {
                    root.tagClicked();
                }
            }

            StatusRoundedImage {
                id: tagImage
                width: 20
                height: 20
                anchors.left: parent.left
                anchors.leftMargin: 2
                anchors.verticalCenter: tagBackground.verticalCenter
                image.fillMode: Image.PreserveAspectFit
                image.source: root.tagImage
            }

            StatusBaseText {
                id: tagName
                width: visible ? (contentWidth+14) : 4
                anchors.left: tagImage.right
                anchors.leftMargin: 4
                anchors.verticalCenter: tagBackground.verticalCenter
                height: 20
                visible: (root.hovered && !!model.communityName)
                opacity: visible ? 1 : 0
                Behavior on opacity { NumberAnimation {} }
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Style.current.tertiaryTextFontSize
                text: root.tagName
            }
        }
    }
}
