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

                isEditMode: ctrlIsEditMode.checked
                communityName: "Status"
                communityIcon: ModelsData.icons.status
                introMessage: "%1 sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.

1. Ut enim ad minim veniam
2. Excepteur sint occaecat cupidatat non proident
3. Duis aute irure
4. Dolore eu fugiat nulla pariatur
5. 🚗 consectetur adipiscing elit

Nemo enim 😋 ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.".arg(dialog.communityName)

                isInvitationPending: ctrlIsInvitationPending.checked
                requirementsCheckPending: ctrlRequirementsCheckPending.checked

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
                onSignProfileKeypairAndAllNonKeycardKeypairs: logs.logEvent("CommunityMembershipSetupDialog::onSignProfileKeypairAndAllNonKeycardKeypairs")
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
                text: dialog.communityName
                onTextChanged: dialog.communityName = text
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
                    font.weight: Font.Bold
                }
                RadioButton {
                    checked: true
                    text: "Status"
                    onCheckedChanged: if(checked) dialog.communityIcon = ModelsData.icons.status
                }
                RadioButton {
                    text: "Crypto Punks"
                    onCheckedChanged: if(checked) dialog.communityIcon = ModelsData.icons.cryptPunks
                }
                RadioButton {
                    text: "Rarible"
                    onCheckedChanged: if(checked) dialog.communityIcon = ModelsData.icons.rarible
                }
                RadioButton {
                    text: "None"
                    onCheckedChanged: if(checked) dialog.communityIcon = ""
                }
            }

            CheckBox {
                id: ctrlIsInvitationPending
                text: "Is invitation pending"
            }

            CheckBox {
                id: ctrlIsEditMode
                visible: !dialog.isInvitationPending
                text: "Is edit mode"
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

            CheckBox {
                id: ctrlRequirementsCheckPending
                visible: !dialog.isInvitationPending && dialog.accessType == Constants.communityChatOnRequestAccess
                text: "Requirements check pending"
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}

// category: Popups

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=31461%3A563897&mode=dev
