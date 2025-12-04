import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Components
import StatusQ.Components.private
import StatusQ.Core
import StatusQ.Core.Theme

import utils

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
        color: StatusColors.transparent
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
