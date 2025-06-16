import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0

import AppLayouts.Profile.stores 1.0

StatusDialog {
    id: root

    property EnsUsernamesStore ensUsernamesStore

    title: qsTr("Primary username")
    standardButtons: Dialog.ApplyRole
    implicitWidth: 400

    onApplied: {
        ensUsernamesStore.setPrefferedEnsUsername(d.newUsername);
        close();
    }

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusButton {
                enabled: d.newUsername !== root.ensUsernamesStore.preferredUsername
                text: qsTr("Apply")
                onClicked: {
                    root.applied()
                }
            }
        }
    }

    QtObject {
        id: d

        property string newUsername: root.ensUsernamesStore.preferredUsername
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.padding

        StyledText {
            Layout.fillWidth: true
            text: root.ensUsernamesStore.preferredUsername ?
                  qsTr("Your messages are displayed to others with this username:")
                  :
                  qsTr("Once you select a username, you won’t be able to disable it afterwards. You will only be able choose a different username to display.")
            font.pixelSize: Theme.primaryTextFontSize
            wrapMode: Text.WordWrap
        }

        StyledText {
            visible: root.ensUsernamesStore.preferredUsername
            text: root.ensUsernamesStore.preferredUsername
            font.pixelSize: Theme.secondaryAdditionalTextSize
            font.weight: Font.Bold
        }

        StatusListView {
            id: ensNamesListView

            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitHeight: contentHeight
            model: root.ensUsernamesStore.currentChainEnsUsernamesModel

            delegate: RadioDelegate {
                id: radioDelegate

                width: ListView.view.width
                text: ensUsername
                checked: root.ensUsernamesStore.preferredUsername === ensUsername

                contentItem: StyledText {
                    color: Theme.palette.textColor
                    text: radioDelegate.text
                    rightPadding: radioDelegate.indicator.width + radioDelegate.spacing
                    topPadding: Theme.halfPadding
                }

                StatusMouseArea {
                    anchors.fill: parent
                    onClicked: {
                        parent.checked = true
                        d.newUsername = ensUsername;
                    }
                }
            }
        }
    }

}

