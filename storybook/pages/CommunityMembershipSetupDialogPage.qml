import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import Models 1.0

import shared.popups 1.0
import utils 1.0

import AppLayouts.Wallet.stores 1.0

SplitView {
    SplitView {
        id: root

        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Logs { id: logs }

        readonly property WalletAssetsStore walletAssetStore: WalletAssetsStore {
            assetsWithFilteredBalances: groupedAccountsAssetsModel
        }

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            PopupBackground {
                anchors.fill: parent
            }

            Button {
                anchors.centerIn: parent
                text: "Reopen"

                onClicked: dialog.open()
            }

            CommunityMembershipSetupDialog {
                id: dialog

                anchors.centerIn: parent
                visible: true
                modal: false
                closePolicy: Popup.NoAutoClose

                communityName: "Status"
                communityIcon: ModelsData.icons.status
                introMessage: "%1 sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.

1. Ut enim ad minim veniam
2. Excepteur sint occaecat cupidatat non proident
3. Duis aute irure
4. Dolore eu fugiat nulla pariatur
5. 🚗 consectetur adipiscing elit

Nemo enim 😋 ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.".arg(dialog.name)
                requirementsCheckPending: false

                walletAccountsModel: WalletAccountsModel {}
                walletAssetsModel: root.walletAssetStore.groupedAccountAssetsModel
                permissionsModel: dialog.accessType === Constants.communityChatOnRequestAccess ? PermissionsModel.complexPermissionsModel
                                                                                               : null
                assetsModel: AssetsModel {}
                collectiblesModel: CollectiblesModel {}

                onCancelMembershipRequest: logs.logEvent("CommunityMembershipSetupDialog::onCancelMembershipRequest()")

                onPrepareForSigning: logs.logEvent("CommunityMembershipSetupDialog::onPrepareForSigning", ["airdropAddress", "sharedAddresses"], arguments)
                onJoinCommunity: logs.logEvent("CommunityMembershipSetupDialog::onJoinCommunity")
                onEditRevealedAddresses: logs.logEvent("CommunityMembershipSetupDialog::editRevealedAddresses")
                onSignProfileKeypairAndAllNonKeycardKeypairs: logs.logEvent("CommunityMembershipSetupDialog::editRevealedAddresses")
                onSignSharedAddressesForKeypair: logs.logEvent("CommunityMembershipSetupDialog::onSignSharedAddressesForKeypair", ["keyUid"], arguments)
                onSharedAddressesUpdated: logs.logEvent("CommunityMembershipSetupDialog::onSharedAddressesUpdated", ["sharedAddresses"], arguments)
                getCurrencyAmount: function (balance, symbol) {
                    return ({
                                amount: balance,
                                symbol: symbol.toUpperCase(),
                                displayDecimals: 2,
                                stripTrailingZeroes: false
                            })
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            anchors.fill: parent

            Label {
                Layout.fillWidth: true
                text: "Community name"
                font.weight: Font.Bold
            }

            TextField {
                Layout.fillWidth: true
                text: dialog.name
                onTextChanged: dialog.name = text
            }

            Label {
                Layout.fillWidth: true
                text: "Intro message"
                font.weight: Font.Bold
            }

            TextField {
                Layout.fillWidth: true
                text: dialog.introMessage
                onTextChanged: dialog.introMessage = text
            }

            ColumnLayout {
                Label {
                    Layout.fillWidth: true
                    text: "Icon:"
                }
                RadioButton {
                    checked: true
                    text: "Status"
                    onCheckedChanged: if(checked) dialog.imageSrc = ModelsData.icons.status
                }
                RadioButton {
                    text: "Crypto Punks"
                    onCheckedChanged: if(checked) dialog.imageSrc = ModelsData.icons.cryptPunks
                }
                RadioButton {
                    text: "Rarible"
                    onCheckedChanged: if(checked) dialog.imageSrc = ModelsData.icons.rarible
                }
                RadioButton {
                    text: "None"
                    onCheckedChanged: if(checked) dialog.imageSrc = ""
                }
            }

            ColumnLayout {
                Label {
                    Layout.fillWidth: true
                    text: "Is invitation pending:"
                }

                CheckBox {
                    checked: dialog.isInvitationPending
                    onCheckedChanged:  dialog.isInvitationPending = checked
                }
            }

            ColumnLayout {
                visible: !dialog.isInvitationPending
                Label {
                    Layout.fillWidth: true
                    text: "Access type:"
                }

                RadioButton {
                    checked: true
                    text: qsTr("Public access")
                    onCheckedChanged: dialog.accessType = Constants.communityChatPublicAccess
                }
                RadioButton {
                    text: qsTr("On request")
                    onCheckedChanged: dialog.accessType = Constants.communityChatOnRequestAccess
                }
            }

            ColumnLayout {
                visible: dialog.accessType == Constants.communityChatOnRequestAccess && !dialog.isInvitationPending
                Label {
                    Layout.fillWidth: true
                    text: "Login type"
                }

                ComboBox {
                    id: ctrlLoginType
                    Layout.fillWidth: true
                    model: ["Password","Biometrics","Keycard"]
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}

// category: Popups

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=31461%3A563897&mode=dev
