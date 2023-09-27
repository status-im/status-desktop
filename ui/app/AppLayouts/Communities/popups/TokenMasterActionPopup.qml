import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Communities.panels 1.0

import utils 1.0


StatusDialog {
    id: root

    enum ActionType {
        RemotelyDestruct, Kick, Ban
    }

    title: {
        if (actionType === TokenMasterActionPopup.ActionType.Ban)
            return qsTr("Ban %1").arg(userName)
        if (actionType === TokenMasterActionPopup.ActionType.Kick)
            return qsTr("Kick %1").arg(userName)

        return qsTr("Remotely destruct TokenMaster token")
    }

    implicitWidth: 600

    property int actionType: TokenMasterActionPopup.ActionType.RemotelyDestruct

    property string communityName
    property string userName
    property string networkName
    
    property string feeText
    property string feeErrorText
    property bool isFeeLoading


    property var accountsModel
    readonly property alias selectedAccount: d.accountAddress
    readonly property alias selectedAccountName: d.accountName

    readonly property alias deleteMessages: deleteMessagesSwitch.checked

    readonly property string feeLabel: qsTr("Remotely destruct 1 TokenMaster token on %1").arg(
                                           root.networkName)

    signal remotelyDestructClicked
    signal kickClicked
    signal banClicked

    QtObject {
        id: d

        property string accountAddress: ""
        property string accountName: ""
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        StatusBaseText {
            Layout.fillWidth: true
            text: {
                if (root.actionType === TokenMasterActionPopup.ActionType.RemotelyDestruct)
                    return qsTr('Continuing will destroy the TokenMaster token held by <span style="font-weight:600;">%1</span> and revoke the permissions they have by virtue of holding this token.')
                        .arg(root.userName)

                if (root.actionType === TokenMasterActionPopup.ActionType.Kick)
                    return qsTr('Are you sure you kick <span style="font-weight:600;">%1</span> from %2? <span style="font-weight:600;">%1</span> is a TokenMaster hodler. In order to kick them you must also remotely destruct their TokenMaster token to revoke the permissions they have by virtue of holding this token.')
                        .arg(root.userName).arg(root.communityName)

                if (root.actionType === TokenMasterActionPopup.ActionType.Ban)
                    return qsTr('Are you sure you ban <span style="font-weight:600;">%1</span> from %2? <span style="font-weight:600;">%1</span> is a TokenMaster hodler. In order to kick them you must also remotely destruct their TokenMaster token to revoke the permissions they have by virtue of holding this token.')
                        .arg(root.userName).arg(root.communityName)
            }

            textFormat: Text.RichText
            wrapMode: Text.Wrap
            lineHeight: 22
            lineHeightMode: Text.FixedHeight
        }

        Rectangle {
            Layout.bottomMargin: 2
            Layout.preferredHeight: 1
            Layout.fillWidth: true

            visible: root.actionType
                     !== TokenMasterActionPopup.ActionType.RemotelyDestruct
            color: Theme.palette.baseColor2
        }

        RowLayout {
            visible: root.actionType === TokenMasterActionPopup.ActionType.Ban

            StatusBaseText {
                Layout.fillWidth: true

                text: qsTr("Delete all messages posted by the user")
                color: Theme.palette.directColor1
                font.pixelSize: Theme.primaryTextFontSize
            }

            StatusSwitch {
                id: deleteMessagesSwitch

                checked: true
                verticalPadding: 2
            }
        }

        RowLayout {
            Layout.bottomMargin: 2

            visible: root.actionType
                     !== TokenMasterActionPopup.ActionType.RemotelyDestruct

            StatusBaseText {
                Layout.fillWidth: true

                text: qsTr("Remotely destruct 1 TokenMaster token")
                color: Theme.palette.directColor1
                font.pixelSize: Theme.primaryTextFontSize
            }

            StatusSwitch {
                id: remotelyDestructSwitch

                checked: true
                enabled: false
                verticalPadding: 2
            }
        }

        FeesBox {
            Layout.fillWidth: true

            implicitWidth: 0

            accountsSelector.model: root.accountsModel
            accountErrorText: root.feeErrorText

            model: QtObject {
                id: singleFeeModel

                readonly property string title: root.feeLabel
                readonly property string feeText: root.isFeeLoading ?
                                                  "" : root.feeText
                readonly property bool error: root.feeErrorText !== ""
            }

            accountsSelector.onCurrentIndexChanged: {
                if (accountsSelector.currentIndex < 0)
                    return

                const item = ModelUtils.get(accountsSelector.model,
                                            accountsSelector.currentIndex)
                d.accountAddress = item.address
                d.accountName = item.name
            }
        }
    }

    footer: StatusDialogFooter {
        spacing: Style.current.padding

        rightButtons: ObjectModel {
            StatusFlatButton {
                text: qsTr("Cancel")
                onClicked: close()
            }
            StatusButton {
                enabled: !root.isFeeLoading && root.feeErrorText === ""
                text: {
                    if (root.actionType === TokenMasterActionPopup.ActionType.Ban)
                        return qsTr("Ban %1 and remotely destruct 1 token").arg(root.userName)

                    if (root.actionType === TokenMasterActionPopup.ActionType.Kick)
                        return qsTr("Kick %1 and remotely destruct 1 token").arg(root.userName)

                    return qsTr("Remotely destruct 1 token")
                }

                type: StatusBaseButton.Type.Danger
                onClicked: {
                    if (root.actionType === TokenMasterActionPopup.ActionType.RemotelyDestruct)
                        root.remotelyDestructClicked()
                    else if (root.actionType === TokenMasterActionPopup.ActionType.Ban)
                        root.banClicked()
                    else if (root.actionType === TokenMasterActionPopup.ActionType.Kick)
                        root.kickClicked()
                }
            }
        }
    }
}
