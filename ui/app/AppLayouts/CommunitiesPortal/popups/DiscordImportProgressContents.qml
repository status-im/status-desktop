import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1

import "../controls"

StatusScrollView {
    id: root

    property var store

    signal close()

    implicitWidth: childrenRect.width
    padding: 0

    enum ImportStatus {
        Unknown,
        InProgress,
        Stopped,
        StoppedWithErrors,
        CompletedWithWarnings,
        CompletedSuccessfully
    }

    readonly property list<StatusBaseButton> rightButtons: [
        StatusButton {
            visible: d.status === DiscordImportProgressContents.ImportStatus.CompletedWithWarnings ||
                     d.status === DiscordImportProgressContents.ImportStatus.StoppedWithErrors
            type: StatusButton.Danger
            font.weight: Font.Medium
            text: qsTr("Delete community & restart import")
            onClicked: {
                // TODO display a confirmation and open CreateCommunityPopup again
                root.close()
            }
        },
        StatusButton {
            visible: d.status === DiscordImportProgressContents.ImportStatus.InProgress
            type: StatusButton.Danger
            font.weight: Font.Medium
            text: qsTr("Cancel import")
            onClicked: {
                // TODO display a confirmation popup and actually cancel
                root.close()
            }
        },
        StatusButton {
            visible: d.status === DiscordImportProgressContents.ImportStatus.Stopped // TODO find out exactly when to display this button
            type: StatusButton.Danger
            font.weight: Font.Medium
            text: qsTr("Restart import")
            onClicked: {
                // TODO display a confirmation and open CreateCommunityPopup again
                root.close()
            }
        },
        StatusButton {
            visible: d.status === DiscordImportProgressContents.ImportStatus.InProgress
            font.weight: Font.Medium
            text: qsTr("Hide window")
            onClicked: root.close()
        },
        StatusButton {
            visible: d.status === DiscordImportProgressContents.ImportStatus.CompletedSuccessfully ||
                     d.status === DiscordImportProgressContents.ImportStatus.CompletedWithWarnings
            font.weight: Font.Medium
            text: qsTr("Visit your new Status community")
            onClicked: {
                root.close()
                root.store.setActiveCommunity(root.store.discordImportCommunityId)
            }
        }
    ]

    QtObject {
        id: d

        readonly property var helperInfo: {
            "import.communityCreation": {
                icon: "network",
                text: qsTr("Setting up your community")
            },
            "import.channelsCreation": {
                icon: "channel",
                text: qsTr("Importing channels")
            },
            "import.importMessages": {
                icon: "receive",
                text: qsTr("Importing messages")
            },
            "import.downloadAssets": {
                icon: "image",
                text: qsTr("Downloading assets")
            }
        }

        readonly property int importProgress: root.store.discordImportProgress // FIXME for now it is 0..100
        readonly property bool importStopped: root.store.discordImportProgressStopped
        readonly property bool hasErrors: root.store.discordImportErrorsCount
        readonly property bool hasWarnings: root.store.discordImportWarningsCount

        readonly property int status: {
            if (importStopped) {
                if (hasErrors)
                    return DiscordImportProgressContents.ImportStatus.StoppedWithErrors
                return DiscordImportProgressContents.ImportStatus.Stopped
            }
            if (importProgress >= 100) {
                if (hasWarnings)
                    return DiscordImportProgressContents.ImportStatus.CompletedWithWarnings
                return DiscordImportProgressContents.ImportStatus.CompletedSuccessfully
            }
            if (importProgress > 0 && importProgress < 100)
                return DiscordImportProgressContents.ImportStatus.InProgress
            return DiscordImportProgressContents.ImportStatus.Unknown
        }

        function getSubtaskDescription(progress) {
            if (progress > 0 && (importStopped || hasErrors))
                return qsTr("Import stopped...")
            if (importStopped)
                return ""
            if (progress >= 1.0)
                return qsTr("✓ Complete")
            if (progress <= 0.0)
                return qsTr("Pending...")
            return qsTr("Working...")
        }
    }

    Component {
        id: subtaskComponent
        ColumnLayout {
            spacing: 40
            width: parent.width

            RowLayout {
                id: subtaskRow
                spacing: 12
                Layout.fillWidth: true
                Layout.preferredHeight: 42

                StatusRoundIcon {
                    id: subtaskIcon
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    icon.name: d.helperInfo[model.type].icon
                }
                ColumnLayout {
                    spacing: 4
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter
                    StatusBaseText {
                        font.pixelSize: 15
                        text: d.helperInfo[model.type].text
                    }
                    StatusBaseText {
                        font.pixelSize: 12
                        color: {
                            if (model.progress > 0 && d.hasErrors)
                                return Theme.palette.dangerColor1
                            if (model.progress >= 1)
                                return Theme.palette.successColor1
                            return Theme.palette.baseColor1
                        }
                        text: d.getSubtaskDescription(model.progress)
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
                    visible: value > 0 && value <= 1 && d.status !== DiscordImportProgressContents.ImportStatus.StoppedWithErrors
                    fillColor: Theme.palette.primaryColor1
                    backgroundColor: Theme.palette.directColor8
                    value: model.progress
                }
            }
            ColumnLayout {
                id: errorsColumn
                Layout.fillWidth: true
                Layout.leftMargin: subtaskIcon.width + subtaskRow.spacing
                spacing: 12
                property var errorsModel: model.errors

                Repeater {
                    model: errorsColumn.errorsModel
                    delegate: IssuePill {
                        Layout.fillWidth: true
                        horizontalPadding: 12
                        verticalPadding: 8
                        bgCornerRadius: 8
                        visible: text
                        type: model.code === 2 ? IssuePill.Type.Error : IssuePill.Type.Warning
                        text: model.message
                    }
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
                text: {
                    switch (d.status) {
                    case DiscordImportProgressContents.ImportStatus.InProgress:
                        return qsTr("Importing ‘%1’ from Discord...").arg(root.store.discordImportCommunityId)
                    case DiscordImportProgressContents.ImportStatus.Stopped:
                        return qsTr("Importing ‘%1’ from Discord stopped...").arg(root.store.discordImportCommunityId)
                    case DiscordImportProgressContents.ImportStatus.StoppedWithErrors:
                        return qsTr("Importing ‘%1’ stopped due to a critical issue...").arg(root.store.discordImportCommunityId)
                    case DiscordImportProgressContents.ImportStatus.CompletedWithWarnings:
                        return qsTr("‘%1’ was imported with %n issue(s).", "", root.store.discordImportWarningsCount).arg(root.store.discordImportCommunityId)
                    case DiscordImportProgressContents.ImportStatus.CompletedSuccessfully:
                        return qsTr("‘%1’ was successfully imported from Discord.").arg(root.store.discordImportCommunityId)
                    default:
                        return qsTr("Your Discord community import is in-progress...")
                    }
                }
            }
            Item { Layout.fillWidth: true }
            IssuePill {
                type: d.hasErrors ? IssuePill.Type.Error : IssuePill.Type.Warning
                count: d.hasErrors ? root.store.discordImportErrorsCount :
                                     d.hasWarnings ? root.store.discordImportWarningsCount : 0
                visible: count
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
                    model: root.store.discordImportTasks
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
            text: d.status === DiscordImportProgressContents.ImportStatus.InProgress ?
                      qsTr("This process can take a while. Feel free to hide this window and use Status normally in the meantime. We’ll notify you when the Community is ready for you.") :
                      qsTr("If there were any issues with your import you can upload new JSON files via the community page at any time.")
        }
    }
}
