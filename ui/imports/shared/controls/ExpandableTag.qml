import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

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
    property bool isIcon: false
    property color backgroundColor: Theme.palette.baseColor4

    property bool expanded: root.hovered

    signal tagClicked()

    contentItem: Item {

        StatusBaseText {
            id: textLabel
            width:  parent.width
            visible: root.expanded && !!root.tagHeaderText
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
            width: Math.min(Math.max(tagRowLayout.implicitWidth + tagRowLayout.anchors.margins * 2, 24), parent.width)
            Behavior on width { NumberAnimation {} }
            height: 24
            anchors.top: textLabel.bottom
            anchors.topMargin: 4
            radius: parent.width/2
            color: root.backgroundColor
            StatusMouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: hovered ? Qt.PointingHandCursor : undefined
                onClicked: {
                    root.tagClicked();
                }
            }

            RowLayout {
                id: tagRowLayout
                anchors.fill: parent
                anchors.margins: 2
                spacing: 4

                Loader {
                    id: tagImageLoader
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    Layout.alignment: Qt.AlignVCenter
                    sourceComponent: root.isIcon ? tagStatusRoundIcon : tagStatusRoundedImage
                }

                StatusBaseText {
                    id: tagName
                    Layout.preferredHeight: 20
                    Layout.fillWidth: true
                    Layout.rightMargin: 2
                    visible: (root.expanded && !!root.tagName)
                    opacity: visible ? 1 : 0
                    Behavior on opacity { NumberAnimation {} }
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Theme.tertiaryTextFontSize
                    text: root.tagName
                    elide: Text.ElideRight
                }
            }
        }
    }

    Component {
        id: tagStatusRoundedImage
        StatusRoundedImage {
            image.fillMode: Image.PreserveAspectFit
            image.source: root.tagImage
        }
    }

    Component {
        id: tagStatusRoundIcon
        StatusRoundIcon {
            asset.width: 16
            asset.height: 16
            color: "transparent"
            asset.name: root.tagImage
            asset.color: tagName.color
        }
    }
}
