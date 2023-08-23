import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtQml.Models 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import AppLayouts.Profile.controls 1.0
import AppLayouts.Wallet 1.0

import shared.panels 1.0
import utils 1.0

StatusDialog {
    id: root

    property string name
    property var relatedAccounts
    property var getNetworkShortNames: function(chainIds){}

    signal confirmClicked()

    title: qsTr("Remove %1 keypair").arg(name)
    width: 521

    ColumnLayout {
        anchors.fill: parent
        spacing: Style.current.xlPadding

        StatusBaseText {
            Layout.fillWidth: true
            text: qsTr("Are you sure you want to remove %1 keypair? The keypair will be removed from all of your synced devices. Make sure you have a backup of your keys or seed phrase before proceeding.").arg(name)
            wrapMode: Text.WordWrap
            font.pixelSize: 15
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            StatusBaseText {
                text: qsTr("Accounts related to this keypair will also be removed:")
                font.pixelSize: 15
            }

            StatusScrollView {
                id: scrolView1
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: availableWidth
                Rectangle {
                    implicitWidth: scrolView1.availableWidth
                    implicitHeight: listview.height
                    color: Theme.palette.transparent
                    border.color: Theme.palette.baseColor2
                    border.width: 1
                    radius: 8
                    clip: true
                    Column {
                        id: listview
                        width: scrolView1.availableWidth
                        Repeater {
                            id: repeater
                            model: root.relatedAccounts
                            delegate: WalletAccountDelegate {
                                id: delegate
                                width: parent.width
                                account : model.account
                                getNetworkShortNames: root.getNetworkShortNames
                                color: Theme.palette.transparent
                                nextIconVisible: false
                                components: StatusBaseText {
                                    font.pixelSize: 15
                                    text: LocaleUtils.currencyAmountToLocaleString(!!account ? account.balance: "")
                                }
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    width: parent.width
                                    height: 1
                                    color: Theme.palette.baseColor2
                                    visible: index < repeater.count - 1
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusButton {
                text: qsTr("Cancel")
                onClicked : root.close()
            }
            StatusButton {
                type: StatusBaseButton.Type.Danger
                text: qsTr("Remove keypair and derived accounts")
                onClicked: root.confirmClicked()
                Keys.onReturnPressed: function(event) {
                    root.confirmClicked()
                }
            }
        }
    }
}
