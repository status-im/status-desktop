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
                visible: root.store.discordImportProgress < 1.0
                type: StatusButton.Danger
                font.weight: Font.Medium
                text: qsTr("Cancel import")
                onClicked: {
                    // TODO display a confirmation popup
                    root.close()
                }
            }
            StatusButton {
                visible: root.store.discordImportProgressStopped
                type: StatusButton.Danger
                font.weight: Font.Medium
                text: qsTr("Restart import")
                onClicked: {
                    // TODO display a confirmation and open CreateCommunityPopup again
                    root.close()
                }
            }
            StatusButton {
                visible: root.store.discordImportProgress < 1.0
                font.weight: Font.Medium
                text: qsTr("Hide window")
                onClicked: root.close()
            }
            StatusButton {
                visible: root.store.discordImportProgress >= 1.0 && !root.store.discordImportProgressStopped
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

        function getSubtaskDescription(progress) {
            if (progress >= 1.0)
                return qsTr("✓ Complete")
            if (progress > 0 && root.store.discordImportProgressStopped)
                return qsTr("Import stopped...")
            if (root.store.discordImportProgressStopped)
                return ""
            if (progress <= 0.0)
                return qsTr("Pending...")
            return qsTr("Working...")
        }

        ListElement {
            icon: "network"
            primary: qsTr("Setting up your community")
            progress: 1.0
        }
        ListElement {
            icon: "channel"
            primary: qsTr("Importing categories & channels")
            progress: 0.52
        }
        ListElement {
            icon: "image"
            primary: qsTr("Downloading assets")
            progress: 0.0
        }
        ListElement {
            icon: "receive"
            primary: qsTr("Importing messages")
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
                        color: {
                            if (model.progress >= 1)
                                return Theme.palette.successColor1
                            if (model.progress > 0 && root.store.discordImportProgressStopped)
                                return Theme.palette.dangerColor1
                            return Theme.palette.baseColor1
                        }
                        text: mockModel.getSubtaskDescription(model.progress)
                    }
                }
                Item { Layout.fillWidth: true }
                StatusBaseText {
                    Layout.alignment: Qt.AlignVCenter
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    visible: subtaskProgressBar.visible
                    text: qsTr("%1%").arg(Math.round(model.progress*100))
                }
                StatusProgressBar {
                    id: subtaskProgressBar
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 130
                    Layout.preferredHeight: 10
                    visible: value > 0 && value <= 1 && !root.store.discordImportProgressStopped
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
                StatusBaseText { // TODO use the error/warning pill component
                    visible: !!text
                    text: root.store.discordImportErrorsCount ? qsTr("%n error(s)", "", root.store.discordImportErrorsCount) :
                                                                root.store.discordImportWarningsCount ? qsTr("%n warning(s)", "", root.store.discordImportWarningsCount) : ""
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
