import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Components 0.1
import StatusQ.Components.private 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Control {
    id: root

    property bool selected
    property bool forceHovered

    property string text: qsTr("Select token")

    property string name
    property url icon

    signal clicked

    padding: 10

    background: StatusComboboxBackground {
        border.width: 0
        color: {
            if (root.selected)
                return "transparent"

            return root.hovered || root.forceHovered
                    ? Theme.palette.primaryColor2
                    : Theme.palette.primaryColor3
        }
    }

    contentItem: Loader {
        sourceComponent: root.selected ? selectedContent : notSelectedContent
    }

    Component {
        id: notSelectedContent

        RowLayout {
            objectName: "notSelectedContent"

            spacing: 10

            StatusBaseText {
                objectName: "tokenSelectorContentItemText"
                font.pixelSize: root.font.pixelSize
                font.weight: Font.Medium
                color: Theme.palette.primaryColor1
                text: root.text
            }

            StatusComboboxIndicator {
                color: Theme.palette.primaryColor1
            }
        }
    }

    Component {
        id: selectedContent

        RowLayout {
            objectName: "selectedContent"

            spacing: Theme.halfPadding

            StatusRoundedImage {
                id: tokenSelectorIcon
                objectName: "tokenSelectorIcon"

                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                image.source: root.icon
            }

            StatusBaseText {
                Layout.fillWidth: true

                objectName: "tokenSelectorContentItemText"
                font.pixelSize: 28
                color: root.hovered ? Theme.palette.blue : Theme.palette.darkBlue

                elide: Text.ElideRight
                text: root.name
            }

            StatusComboboxIndicator {
                id: comboboxIndicator

                color: Theme.palette.primaryColor1
            }
        }
    }

    MouseArea {
        cursorShape: root.enabled ? Qt.PointingHandCursor : undefined
        anchors.fill: parent

        onClicked: root.clicked()
    }
}
