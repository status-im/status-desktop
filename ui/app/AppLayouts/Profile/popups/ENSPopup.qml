import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0

StatusDialog {
    id: root

    property var ensUsernamesStore

    title: qsTr("Primary username")
    standardButtons: Dialog.ApplyRole
    implicitWidth: 400

    onApplied: {
        console.log("applied!")
        ensUsernamesStore.setPrefferedEnsUsername(d.newUsername);
        close();
    }

    QtObject {
        id: d

        property string newUsername: ""
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Style.current.padding

        StyledText {
            Layout.fillWidth: true
            text: root.ensUsernamesStore.preferredUsername ?
                  qsTr("Your messages are displayed to others with this username:")
                  :
                  qsTr("Once you select a username, you won’t be able to disable it afterwards. You will only be able choose a different username to display.")
            font.pixelSize: 15
            wrapMode: Text.WordWrap
        }

        StyledText {
            visible: root.ensUsernamesStore.preferredUsername
            text: root.ensUsernamesStore.preferredUsername
            font.pixelSize: 17
            font.weight: Font.Bold
        }

        StatusListView {
            id: ensNamesListView

            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitHeight: contentHeight

            model: root.ensUsernamesStore.ensUsernamesModel

            delegate: RadioDelegate {
                id: radioDelegate

                width: ListView.view.width
                text: ensUsername
                checked: root.ensUsernamesStore.preferredUsername === ensUsername

                contentItem: StyledText {
                    color: Style.current.textColor
                    text: radioDelegate.text
                    rightPadding: radioDelegate.indicator.width + radioDelegate.spacing
                    topPadding: Style.current.halfPadding
                }

                MouseArea {
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

