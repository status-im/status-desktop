import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1 as StatusQControls
import StatusQ.Components 0.1

import utils 1.0
import shared.status 1.0
import shared.popups 1.0
import shared.popups.send 1.0
import shared.stores.send 1.0

import AppLayouts.Profile.stores 1.0

Item {
    id: root
    property EnsUsernamesStore ensUsernamesStore
    property string username: ""
    property int chainId: -1

    signal backBtnClicked()
    signal releaseUsernameRequested(string senderAddress)

    QtObject {
        id: d

        property double expirationTimestamp: 0
        property string walletAddress: "-"
        property string key: "-"
    }

    StatusBaseText {
        id: sectionTitle
        text: username
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
        color: Theme.palette.directColor1
    }

    Component {
        id: loadingImageComponent
        StatusLoadingIndicator {}
    }

    Loader {
        id: loadingImg
        active: false
        sourceComponent: loadingImageComponent
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        anchors.top: parent.top
        anchors.topMargin: Theme.padding
    }

    Connections {
        target: root.ensUsernamesStore.ensUsernamesModule
        function onDetailsObtained(chainId: int, ensName: string, address: string, pubkey: string, isStatus: bool, expirationTime: int) {
            if(username != (isStatus ? ensName + ".stateofus.eth" : ensName))
                return;
            d.walletAddress = address
            walletAddressLbl.subTitle = address;
            walletAddressLbl.visible = !!address;

            d.key = pubkey
            keyLbl.subTitle = pubkey.substring(0, 20) + "..." + pubkey.substring(pubkey.length - 20);
            keyLbl.visible = !!pubkey;

            releaseBtn.visible = isStatus
            removeButton.visible = true
            releaseBtn.enabled = expirationTime > 0
                                 && (Date.now() / 1000) > expirationTime
                                 && root.ensUsernamesStore.preferredUsername !== username
            d.expirationTimestamp = expirationTime * 1000
        }
        function onLoading(isLoading: bool) {
            loadingImg.active = isLoading
            if (!isLoading)
                return;
            walletAddressLbl.visible = false;
            keyLbl.visible = false;
            releaseBtn.visible = false;
            removeButton.visible = false;
            d.expirationTimestamp = 0;
        }
    }

    StatusDescriptionListItem {
        id: walletAddressLbl
        title: qsTr("Wallet address")
        visible: false
        anchors.top: sectionTitle.bottom
        anchors.topMargin: 24
        asset.name: "copy"
        tooltip.text: qsTr("Copied to clipboard!")
        iconButton.onClicked: {
            ClipboardUtils.setText(subTitle)
            tooltip.visible = !tooltip.visible
        }
    }
    StatusDescriptionListItem {
        id: keyLbl
        title: qsTr("Key")
        visible: false
        anchors.top: walletAddressLbl.bottom
        anchors.topMargin: 24
        asset.name: "copy"
        tooltip.text: qsTr("Copied to clipboard!")
        iconButton.onClicked: {
            ClipboardUtils.setText(subTitle)
            tooltip.visible = !tooltip.visible
        }
    }

    RowLayout {
        id: actionsLayout

        anchors.top: keyLbl.bottom
        anchors.topMargin: 24
        anchors.left: parent.left
        anchors.leftMargin: 24

        StatusQControls.StatusButton {
            id: removeButton
            visible: false
            type: StatusQControls.StatusBaseButton.Type.Danger
            text: qsTr("Remove username")
            onClicked: {
                root.ensUsernamesStore.removeEnsUsername(root.chainId, root.username)
                root.backBtnClicked()
            }
        }

        StatusQControls.StatusButton {
            id: releaseBtn
            visible: false
            enabled: false
            text: qsTr("Release username")
            onClicked: {
                root.releaseUsernameRequested(d.walletAddress)
            }
        }
    }

    Text {
        visible: releaseBtn.visible && !releaseBtn.enabled
        anchors.top: actionsLayout.bottom
        anchors.topMargin: 2
        anchors.left: parent.left
        anchors.leftMargin: 24
        text: {
            if (d.expirationTimestamp === 0)
                return ""
            const formattedDate = LocaleUtils.formatDate(d.expirationTimestamp, Locale.ShortFormat)
            return qsTr("Username locked. You won't be able to release it until %1").arg(formattedDate)
        }
        color: Theme.palette.darkGrey
    }

    StatusQControls.StatusButton {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.padding
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Back")
        onClicked: backBtnClicked()
    }
}
