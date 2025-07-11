import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models

import utils

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Popups.Dialog
import StatusQ.Controls

StatusDialog {
    id: root

    width: 400
    title: qsTr("Required assets not held")

    property string userName: ""
    property string communityName: ""
    property string communityId: ""
    property string requestId: ""

    signal rejectButtonClicked(string requestId, string communityId)

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusButton {
                text: qsTr("Reject")
                type: StatusBaseButton.Type.Danger
                icon.name: "close-circle"
                icon.color: Theme.palette.dangerColor1
                onClicked: root.rejectButtonClicked(root.requestId, root.communityId)
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.padding

        StatusBaseText {
            text: qsTr("%1 no longer holds the tokens required to join %2 in their wallet, so their request to join %2 must be rejected.").arg(root.userName).arg(root.communityName)
            wrapMode: Text.WordWrap
            color: Theme.palette.directColor1
            Layout.fillWidth: true
        }

        StatusBaseText {
            text: qsTr("%1 can request to join %2 again in the future, when they have the tokens required to join %2 in their wallet.").arg(root.userName).arg(root.communityName)
            wrapMode: Text.WordWrap
            color: Theme.palette.directColor1
            Layout.fillWidth: true
        }
    }
}
