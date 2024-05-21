import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import shared.controls 1.0

Popup {
    id: root

    objectName: "dappsPopup"

    required property var model

    signal pairWCDapp()

    modal: false
    padding: 8
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnOutsideClick | Popup.CloseOnPressOutside

    background: Rectangle {
        id: backgroundContent

        color: Theme.palette.statusMenu.backgroundColor
        radius: 8
        layer.enabled: true
        layer.effect: DropShadow {
            anchors.fill: parent
            source: backgroundContent
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12
            samples: 25
            spread: 0.2
            color: Theme.palette.dropShadow
        }
    }

    ColumnLayout {
        id: mainLayout

        implicitWidth: 280

        spacing: 8

        ShapeRectangle {
            id: listPlaceholder

            text: qsTr("Connected dApps will appear here")

            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight

            visible: listView.count === 0
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Layout.leftMargin: 8

            visible: !listPlaceholder.visible

            StatusBaseText {
                text: qsTr("Connected dApps")

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                font.pixelSize: 12
                color: Theme.palette.baseColor1
            }
        }

        StatusListView {
            id: listView

            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
            Layout.maximumHeight: 280

            model: root.model
            visible: !listPlaceholder.visible

            delegate: DAppDelegate {
                implicitWidth: listView.width
            }

            ScrollBar.vertical: null
        }

        StatusButton {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight

            text: qsTr("Connect a dApp via WalletConnect")
            onClicked: {
                root.pairWCDapp()
            }
        }
    }

    component DAppDelegate: Item {
        implicitHeight: 50

        required property string name
        required property string url
        required property string iconUrl

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8

            Item {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32

                StatusImage {
                    id: iconImage

                    anchors.fill: parent

                    source: iconUrl
                    visible: !fallbackImage.visible
                }

                StatusIcon {
                    id: fallbackImage

                    anchors.fill: parent

                    icon: "dapp"
                    color: Theme.palette.baseColor1

                    visible: iconImage.isLoading || iconImage.isError || !iconUrl
                }

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: iconImage.width
                        height: iconImage.height
                        radius: width / 2
                        visible: false
                    }
                }
            }

            ColumnLayout {
                Layout.leftMargin: 12
                Layout.rightMargin: 12

                StatusBaseText {
                    text: name

                    Layout.fillWidth: true

                    font.pixelSize: 13
                    font.bold: true

                    elide: Text.ElideRight

                    clip: true
                }
                StatusBaseText {
                    text: url

                    Layout.fillWidth: true

                    font.pixelSize: 12
                    color: Theme.palette.baseColor1

                    elide: Text.ElideRight

                    clip: true
                }
            }

            // TODO #14588 - Show tooltip on hover "Disconnect dApp"
            StatusRoundButton {
                implicitWidth: 32
                implicitHeight: 32
                radius: width / 2

                icon.name: "disconnect"

                onClicked: {
                    console.debug(`TODO #14755 - Disconnect ${name}`)
                    //root.disconnectDapp()
                }
            }
        }
    }
}
