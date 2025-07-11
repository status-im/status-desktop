import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Popups

import utils

CalloutCard {
    id: root

    signal dismiss()
    signal enableLinkPreviewForThisMessage()
    signal enableLinkPreview()
    signal disableLinkPreview()

    implicitHeight: 64
    borderWidth: 0
    topPadding: 13
    bottomPadding: 13
    horizontalPadding: Theme.padding

    contentItem: RowLayout {
        spacing: Theme.halfPadding
        ColumnLayout {
            spacing: 0
            Layout.fillHeight: true
            Layout.fillWidth: true
            StatusBaseText {
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                Layout.fillHeight: true
                font.pixelSize: Theme.additionalTextSize
                font.weight: Font.Medium
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                maximumLineCount: 1
                text: qsTr("Show link previews?")
                objectName: "titleText"
            }
            StatusBaseText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                font.pixelSize: Theme.additionalTextSize
                color: Theme.palette.baseColor1
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                maximumLineCount: 1
                text: qsTr("A preview of your link will be shown here before you send it")
                objectName: "subtitleText"
            }
        }
        ComboBox {
            id: optionsComboBox
            Layout.leftMargin: 12
            Layout.preferredHeight: 38
            leftPadding: 12
            rightPadding: 12
            hoverEnabled: true
            flat: true
            contentItem: RowLayout {
                spacing: Theme.halfPadding
                StatusBaseText {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Theme.additionalTextSize
                    elide: Text.ElideRight
                    text: qsTr("Options")
                    color: Theme.palette.baseColor1
                }
                StatusIcon {
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                    icon: "chevron-down"
                    color: Theme.palette.baseColor1
                }
            }
            background: Rectangle {
                border.width: 1
                border.color: Theme.palette.directColor7
                color: optionsComboBox.popup.visible ? Theme.palette.baseColor2 : "transparent"
                radius: Theme.radius
                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                    enabled: optionsComboBox.enabled
                }
            }
            popup: LinkPreviewSettingsCardMenu {
                y: - (height + 4)
                onEnableLinkPreviewForThisMessage: root.enableLinkPreviewForThisMessage()
                onEnableLinkPreview: root.enableLinkPreview()
                onDisableLinkPreview: root.disableLinkPreview()
            }
            indicator: null
        }

        StatusFlatRoundButton {
            id: closeButton
            objectName: "closeLinkPreviewButton"
            Layout.preferredHeight: 38
            Layout.preferredWidth: 38
            type: StatusFlatRoundButton.Type.Secondary
            icon.name: "close"
            icon.color: Theme.palette.directColor1
            onClicked: root.dismiss()
        }
    }
}
