import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Chat.panels.communities 1.0

import utils 1.0

StatusDialog {
    id: root

    property int tokenCount: 0

    signal remotelyDestructClicked
    signal cancelClicked

    title: qsTr("Remotely destruct %n token(s)", "", root.tokenCount)
    implicitWidth: 400 // by design
    topPadding: Style.current.padding
    bottomPadding: topPadding
    contentItem: StatusBaseText {
        text: qsTr("Continuing will destroy tokens held by members and revoke any perissions they given. To undo you will have to issue them new tokens.")
        font.pixelSize: Style.current.primaryTextFontSize
        wrapMode: Text.WordWrap
        lineHeight: 1.2
    }

    footer: StatusDialogFooter {
        spacing: Style.current.padding
        rightButtons: ObjectModel {

            StatusButton {
                text: qsTr("Cancel")
                normalColor: "transparent"

                onClicked: {
                    root.cancelClicked()
                    close()
                }
            }

            StatusButton {
                text: qsTr("Remotely destruct")
                type: StatusBaseButton.Type.Danger

                onClicked: {
                    root.remotelyDestructClicked()
                    close()
                }
            }
        }
    }
}
