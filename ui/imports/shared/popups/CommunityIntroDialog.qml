import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Communities.panels 1.0

import SortFilterProxyModel 0.2

StatusStackModal {
    id: root

    property string name
    property string introMessage
    property int accessType
    property url imageSrc
    property bool isInvitationPending: false
    property int loginType: Constants.LoginType.Password

    required property var walletAccountsModel // name, address, emoji, colorId
    required property var permissionsModel  // id, key, permissionType, holdingsListModel, channelsListModel, isPrivate, tokenCriteriaMet
    required property var assetsModel
    required property var collectiblesModel

    signal joined(string airdropAddress, var sharedAddresses)
    signal cancelMembershipRequest()

    width: 640 // by design
    padding: 0
    stackTitle: root.accessType === Constants.communityChatOnRequestAccess ? qsTr("Request to join %1").arg(name) : qsTr("Welcome to %1").arg(name)

    rightButtons: [d.shareButton, finishButton]

    finishButton: StatusButton {
        text: root.isInvitationPending ? qsTr("Cancel Membership Request")
                                       : (root.accessType === Constants.communityChatOnRequestAccess
                                          ? qsTr("Share your addresses to join")
                                          : qsTr("Join %1").arg(root.name) )
        type: root.isInvitationPending ? StatusBaseButton.Type.Danger
                                       : StatusBaseButton.Type.Normal
        icon.name: root.accessType === Constants.communityChatOnRequestAccess && !root.isInvitationPending ? Constants.authenticationIconByType[root.loginType] : ""
        onClicked: {
            if (root.isInvitationPending) {
                root.cancelMembershipRequest()
            } else {
                root.joined(d.selectedAirdropAddress, d.selectedSharedAddresses)
            }

            root.close()
        }
    }

    QtObject {
        id: d

        readonly property var tempAddressesModel: SortFilterProxyModel {
            sourceModel: root.walletAccountsModel
            filters: [
                ValueFilter {
                    roleName: "walletType"
                    value: Constants.watchWalletType
                    inverted: true
                }
            ]
            sorters: [
                ExpressionSorter {
                    function isGenerated(modelData) {
                        return modelData.walletType === Constants.generatedWalletType
                    }

                    expression: {
                        return isGenerated(modelLeft)
                    }
                },
                RoleSorter {
                    roleName: "position"
                },
                RoleSorter {
                    roleName: "name"
                }
            ]
        }

        // all non-watched addresses by default, unless selected otherwise below in SharedAddressesPanel
        property var selectedSharedAddresses: tempAddressesModel.count ? ModelUtils.modelToFlatArray(tempAddressesModel, "address") : []
        property string selectedAirdropAddress: selectedSharedAddresses.length ? selectedSharedAddresses[0] : ""

        readonly property var shareButton: StatusFlatButton {
            height: finishButton.height
            visible: !root.isInvitationPending && !root.replaceItem
            borderColor: Theme.palette.baseColor2
            text: qsTr("Select addresses to share")
            onClicked: root.replace(sharedAddressesPanelComponent)
        }
    }

    Component {
        id: sharedAddressesPanelComponent
        SharedAddressesPanel {
            communityName: root.name
            communityIcon: root.imageSrc
            loginType: root.loginType
            walletAccountsModel: root.walletAccountsModel
            permissionsModel: root.permissionsModel
            assetsModel: root.assetsModel
            collectiblesModel: root.collectiblesModel
            onShareSelectedAddressesClicked: {
                d.selectedAirdropAddress = airdropAddress
                d.selectedSharedAddresses = sharedAddresses
                root.replaceItem = undefined // go back, unload us
            }
        }
    }

    stackItems: [
        StatusScrollView {
            id: scrollView
            contentWidth: availableWidth

            ColumnLayout {
                spacing: 24
                width: scrollView.availableWidth

                StatusRoundedImage {
                    id: roundImage

                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredHeight: 64
                    Layout.preferredWidth: Layout.preferredHeight
                    visible: image.status == Image.Loading || image.status == Image.Ready
                    image.source: root.imageSrc
                }

                StatusBaseText {
                    id: introText

                    Layout.fillWidth: true
                    text: root.introMessage || qsTr("Community <b>%1</b> has no intro message...").arg(root.name)
                    color: Theme.palette.directColor1
                    wrapMode: Text.WordWrap
                }
            }
        }
    ]
}
