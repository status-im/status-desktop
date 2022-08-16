import QtQuick 2.14
import QtQuick.Layouts 1.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import shared.controls 1.0

Item {
    id: root

    property alias hyperlink: hyperlinkInput.text
    property alias url: urlInput.text
    readonly property alias removeButton: removeButton

    readonly property var focusItem: hyperlinkInput.input.edit
    property var nextFocusItem: null

    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    RowLayout {
        id: layout

        anchors.fill: parent

        ColumnLayout {
            id: leftLayout

            spacing: 26

            StatusInput {
                id: hyperlinkInput
                objectName: "hyperlinkInput"

                Layout.fillWidth: true
                label: qsTr("Hyperlink Text")
                placeholderText: qsTr("Example: My Myspace Profile")
                charLimit: 24

                input.tabNavItem: urlInput.input.edit
            }

            StatusInput {
                id: urlInput
                objectName: "urlInput"

                Layout.fillWidth: true
                label: qsTr("URL")
                placeholderText: qsTr("Link URL")

                input.tabNavItem: root.nextFocusItem
            }
        }

        Item {
            Layout.preferredWidth: 280
            Layout.fillHeight: true

            clip: true

            ColumnLayout {
                x: 64

                anchors.verticalCenter: parent.verticalCenter

                spacing: 10

                StatusBaseText {
                    text: qsTr("Preview")
                    color: Theme.palette.baseColor1
                    font.pixelSize: 15
                }

                SocialLinkPreview {
                    Layout.preferredHeight: 32
                    text: !!hyperlinkInput.text ? hyperlinkInput.text : qsTr("My Myspace Profile")
                    url: !!urlInput.text ? urlInput.text : urlInput.placeholderText
                    linkType: Constants.socialLinkType.custom
                }
            }
        }
    }


    StatusFlatButton {
        id: removeButton

        anchors {
            right: parent.right
            top: parent.top
        }

        icon.name: "delete"
        text: qsTr("Remove")
        size: StatusBaseButton.Small
    }
}
