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

    property string text: qsTr("Select asset")

    property string name
    property string subname
    property url icon

    signal clicked

    padding: 10

    background: StatusComboboxBackground {
        border.width: 1
        color: Theme.palette.transparent
    }

    contentItem: Loader {
        sourceComponent: root.selected ? selectedContent : notSelectedContent
    }

    Component {
        id: notSelectedContent

        RowLayout {
            spacing: 10

            StatusBaseText {
                Layout.fillWidth: true

                objectName: "tokenSelectorContentItemText"
                font.pixelSize: Theme.additionalTextSize
                font.weight: Font.Medium
                color: Theme.palette.primaryColor1
                text: root.text

                elide: Text.ElideRight
            }

            StatusComboboxIndicator {
                color: Theme.palette.primaryColor1
            }
        }
    }

    Component {
        id: selectedContent

        RowLayout {
            spacing: Theme.halfPadding

            RowLayout {
                objectName: "selectedTokenItem"
                spacing: Theme.halfPadding

                StatusRoundedImage {
                    objectName: "tokenSelectorIcon"
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    image.source: root.icon
                }

                StatusBaseText {
                    objectName: "tokenSelectorContentItemName"

                    Layout.fillWidth: true

                    // Using Math.ceil prevents undesired elision for some texts
                    Layout.maximumWidth: Math.ceil(implicitWidth)

                    color: Theme.palette.directColor1
                    text: root.name

                    elide: Text.ElideRight
                }

                StatusBaseText {
                    objectName: "tokenSelectorContentItemSymbol"

                    Layout.fillWidth: true

                    color: Theme.palette.baseColor1
                    text: root.subname
                }

                StatusComboboxIndicator {
                    color: Theme.palette.primaryColor1
                }
            }
        }
    }

    StatusMouseArea {
        cursorShape: root.enabled ? Qt.PointingHandCursor : undefined
        anchors.fill: parent

        onClicked: root.clicked()
    }
}
