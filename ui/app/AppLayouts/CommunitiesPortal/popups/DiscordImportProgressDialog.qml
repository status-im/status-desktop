import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialog {
    id: root

    property var store

    title: qsTr("Import a community from Discord into Status")

    horizontalPadding: 16
    verticalPadding: 20
    width: 640

    onClosed: destroy()

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusButton {
                visible: false
                type: StatusButton.Danger
                font.weight: Font.Medium
                text: qsTr("Delete community & restart import")
                onClicked: {
                    // TODO display a confirmation and open CreateCommunityPopup again
                    root.close()
                }
            }
            StatusButton {
                type: StatusButton.Danger
                font.weight: Font.Medium
                text: qsTr("Cancel import")
                onClicked: {
                    // TODO display a confirmation popup
                    root.close()
                }
            }
            StatusButton {
                visible: false
                type: StatusButton.Danger
                font.weight: Font.Medium
                text: qsTr("Restart import")
                onClicked: {
                    // TODO display a confirmation and open CreateCommunityPopup again
                    root.close()
                }
            }
            StatusButton {
                font.weight: Font.Medium
                text: qsTr("Hide window")
                onClicked: root.close()
            }
            StatusButton {
                visible: false
                font.weight: Font.Medium
                text: qsTr("Visit your new Status community")
                onClicked: {
                    root.close()
                    // TODO redirect user to the newly imported community page
                }
            }
        }
    }

    background: StatusDialogBackground {
        color: Theme.palette.baseColor4
    }

    ListModel {
        id: mockModel
        ListElement {
            icon: "network"
            primary: qsTr("Setting up your community")
            secondary: qsTr("Pending...")
            progress: 0.0
        }
        ListElement {
            icon: "channel"
            primary: qsTr("Importing categories & channels")
            secondary: qsTr("Creating status-network channel...")
            progress: 0.52
        }
        ListElement {
            icon: "image"
            primary: qsTr("Downloading assets")
            secondary: qsTr("Pending...")
            progress: 0.0
        }
        ListElement {
            icon: "receive"
            primary: qsTr("Importing messages")
            secondary: qsTr("Pending...")
            progress: 0.0
        }
    }

    Component {
        id: subtaskComponent
        ColumnLayout {
            spacing: 40
            width: parent.width

            RowLayout {
                spacing: 12
                Layout.fillWidth: true
                Layout.preferredHeight: 42

                StatusRoundIcon {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    icon.name: model.icon
                }
                ColumnLayout {
                    spacing: 4
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter
                    StatusBaseText {
                        font.pixelSize: 15
                        text: model.primary
                    }
                    StatusBaseText {
                        font.pixelSize: 12
                        color: Theme.palette.baseColor1
                        text: model.secondary
                    }
                }
                Item { Layout.fillWidth: true }
                StatusBaseText {
                    Layout.alignment: Qt.AlignVCenter
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    visible: model.progress
                    text: qsTr("%1%").arg(Math.round(model.progress*100))
                }
                StatusProgressBar {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 130
                    Layout.preferredHeight: 10
                    visible: value > 0
                    fillColor: Theme.palette.primaryColor1
                    backgroundColor: Theme.palette.directColor8
                    value: model.progress
                }
            }
            StatusDialogDivider {
                Layout.fillWidth: true
                Layout.leftMargin: -24 // compensate for Control.horizontalPadding -> full width
                Layout.rightMargin: -24 // compensate for Control.horizontalPadding -> full width
                visible: !parent.Positioner.isLastItem
            }
        }
    }

    contentItem: StatusScrollView { // TODO extract this
        padding: 0
        width: root.availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 20

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Image {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    sourceSize: Qt.size(36, 36)
                    source: Style.svg("contact") // TODO community icon
                }
                StatusBaseText {
                    Layout.fillWidth: true
                    font.pixelSize: 15
                    text: qsTr("Importing ‘%1’ from Discord...").arg("CryptoKitties") // TODO community name
                }
                Item { Layout.fillWidth: true }
                StatusBaseText {
                    text: "2 errors" // TODO real errors/warnings
                }
            }

            Control {
                Layout.fillWidth: true
                horizontalPadding: 24
                verticalPadding: 40
                background: Rectangle {
                    radius: 16
                    color: Theme.palette.indirectColor1
                    border.width: 1
                    border.color: Theme.palette.directColor8
                }
                contentItem: Column {
                    spacing: 40

                    Repeater {
                        model: mockModel
                        delegate: subtaskComponent
                    }
                }
            }

            StatusBaseText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Qt.AlignHCenter
                wrapMode: Text.WordWrap
                font.pixelSize: 13
                text: qsTr("This process can take a while. Feel free to hide this window and use Status normally in the meantime. We’ll notify you when the Community is ready for you.")
            }
        }
    }
}
