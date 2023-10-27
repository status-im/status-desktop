import QtQuick 2.15
import QtQml.Models 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Communities.panels 1.0

import utils 1.0

StatusDialog {
    id: root

    property bool isEditMode

    property bool requirementsCheckPending
    property var keypairSigningModel

    required property string communityName
    required property string communityIcon
    property int loginType: Constants.LoginType.Password

    required property var walletAccountsModel // name, address, emoji, colorId, assets
    required property var permissionsModel  // id, key, permissionType, holdingsListModel, channelsListModel, isPrivate, tokenCriteriaMet
    required property var assetsModel
    required property var collectiblesModel

    signal shareSelectedAddressesClicked(string airdropAddress, var sharedAddresses)
    signal sharedAddressesChanged(string airdropAddress, var sharedAddresses)

    signal prepareForSigning(string airdropAddress, var sharedAddresses)
    signal editRevealedAddresses()
    signal signSharedAddressesForAllNonKeycardKeypairs()
    signal signSharedAddressesForKeypair(string keyUid)

    function setOldSharedAddresses(oldSharedAddresses) {
        if (!d.displaySigningPanel && !!loader.item) {
            d.oldSharedAddresses = oldSharedAddresses
            loader.item.setOldSharedAddresses(oldSharedAddresses)
        }
    }

    function setOldAirdropAddress(oldAirdropAddress) {
        if (!d.displaySigningPanel && !!loader.item) {
            d.oldAirdropAddress = oldAirdropAddress
            loader.item.setOldAirdropAddress(oldAirdropAddress)
        }
    }

    function sharedAddressesForAllNonKeycardKeypairsSigned() {
        if (d.displaySigningPanel && !!loader.item) {
            loader.item.sharedAddressesForAllNonKeycardKeypairsSigned()
        }
    }

    title: !!loader.item? loader.item.title : ""
    implicitWidth: 640 // by design
    padding: 0

    QtObject {
        id: d

        property bool displaySigningPanel: false
        property bool allSigned: false

        property var oldSharedAddresses
        property string oldAirdropAddress

        property var selectAddressesPanelButtons: ObjectModel {}
        readonly property var signingPanelButtons: ObjectModel {
            StatusFlatButton {
                visible: root.isEditMode
                borderColor: Theme.palette.baseColor2
                text: qsTr("Cancel")
                onClicked: root.close()
            }
            StatusButton {
                text: qsTr("Save changes")
                enabled: d.allSigned
                onClicked: {
                    root.editRevealedAddresses()
                    root.close()
                }
            }
        }

        readonly property var signingPanelBackButtons: ObjectModel {
            StatusBackButton {
                onClicked: {
                    d.displaySigningPanel = false
                }
            }
        }
    }

    contentItem: Loader {
        id: loader
        sourceComponent: d.displaySigningPanel? sharedAddressesSigningPanelComponent : selectSharedAddressesPanelComponent

        onLoaded: {
            if (!d.displaySigningPanel) {
                if (!!d.oldSharedAddresses) {
                    root.setOldSharedAddresses(d.oldSharedAddresses)
                }
                if (!!d.oldAirdropAddress) {
                    root.setOldAirdropAddress(d.oldAirdropAddress)
                }
                d.selectAddressesPanelButtons = loader.item.buttons
            }
        }
    }

    Component {
        id: selectSharedAddressesPanelComponent
        SharedAddressesPanel {
            isEditMode: root.isEditMode
            requirementsCheckPending: root.requirementsCheckPending
            communityName: root.communityName
            communityIcon: root.communityIcon
            loginType: root.loginType
            walletAccountsModel: root.walletAccountsModel
            permissionsModel: root.permissionsModel
            assetsModel: root.assetsModel
            collectiblesModel: root.collectiblesModel
            onShareSelectedAddressesClicked: root.shareSelectedAddressesClicked(airdropAddress, sharedAddresses)
            onPrepareForSigning: {
                root.prepareForSigning(airdropAddress, sharedAddresses)
                d.displaySigningPanel = true
            }
            onSharedAddressesChanged: {
                root.sharedAddressesChanged(airdropAddress, sharedAddresses)
            }
            onClose: root.close()
        }
    }

    Component {
        id: sharedAddressesSigningPanelComponent
        SharedAddressesSigningPanel {

            keypairSigningModel: root.keypairSigningModel

            onSignSharedAddressesForAllNonKeycardKeypairs: {
                root.signSharedAddressesForAllNonKeycardKeypairs()
            }

            onSignSharedAddressesForKeypair: {
                root.signSharedAddressesForKeypair(keyUid)
            }

            onAllSignedChanged: {
                d.allSigned = allSigned
            }
        }
    }

    footer: StatusDialogFooter {
        spacing: Style.current.padding
        rightButtons: d.displaySigningPanel? d.signingPanelButtons : d.selectAddressesPanelButtons
        leftButtons: d.displaySigningPanel? d.signingPanelBackButtons : null
    }
}
