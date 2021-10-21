import QtQuick 2.13
import QtGraphicalEffects 1.13

import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1


import utils 1.0
import "../../Profile/Sections"

Item {
    id: root
    property var store

    Column {
        anchors.top:parent.top
        leftPadding: 20
        rightPadding: 20
        width: parent.width
        spacing: 12

        StatusExpandableItem {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20

            visible : (root.store.walletModelV2Inst.accountsView.currentAccount.walletType !== Constants.seedWalletType) &&
                      (root.store.walletModelV2Inst.accountsView.currentAccount.walletType !== Constants.watchWalletType) &&
                      (root.store.walletModelV2Inst.accountsView.currentAccount.walletType !== Constants.keyWalletType)
            expandable: false
            icon.name: "seed-phrase"
            primaryText: qsTr("Back up seed phrase")
            secondaryText: qsTr("Back up your seed phrase now to secure this account")
            button.text: qsTr("Back up seed phrase")
            button.enabled: !mnemonicModule.isBackedUp
            button.onClicked: backupSeedModal.open()
        }

        StatusExpandableItem {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20

            visible : root.store.walletModelV2Inst.accountsView.currentAccount.walletType !== Constants.watchWalletType
            expandable: true
            icon.name: "secret"
            primaryText: qsTr("Account signing phrase")
            secondaryText: qsTr("View your signing phrase and ensure that you never get scammed")
            expandableComponent: showSigningPhraseExpandableRegion
        }

        StatusExpandableItem {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20

            visible : (root.store.walletModelV2Inst.accountsView.currentAccount.walletType === Constants.keyWalletType) ||
                      (root.store.walletModelV2Inst.accountsView.currentAccount.walletType === Constants.seedWalletType)
            expandable: true
            icon.name: "seed-phrase"
            primaryText: qsTr("View private key")
            secondaryText: qsTr("View your seed phrase and ensure it's stored in a safe place")
            button.text: qsTr("View private key")
            expandableComponent: notImplemented
            button.onClicked: {
                // To-do open  enter password Modal
                expanded = !expanded;
            }
        }

        StatusExpandableItem {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20

            expandable: true
            icon.name: "security"
            primaryText: qsTr("Security preferences")
            secondaryText: qsTr("View & set security preferences for this wallet")
            expandableComponent: notImplemented
        }
    }

    Component {
        id: notImplemented
        Rectangle {
            anchors.centerIn: parent
            width: 654
            height: infoText.implicitHeight
            color: Theme.palette.baseColor5
            StatusBaseText {
                id: infoText
                anchors.centerIn: parent
                color: Theme.palette.directColor4
                font.pixelSize: 15
                lineHeight: 22
                lineHeightMode: Text.FixedHeight
                font.weight: Font.Medium
                text: qsTr("Not Implemented")
            }
        }
    }

    Component {
        id: showSigningPhraseExpandableRegion
        Row {
            spacing: 1
            anchors.centerIn: parent
            width: 654
            Rectangle {
                id: keyRect
                color: Theme.palette.baseColor5
                width: Math.min(keyText.implicitWidth, 200) + keyText.anchors.leftMargin + keyText.anchors.rightMargin
                height: Math.max(keyText.implicitHeight, infoText.implicitHeight) + 42
                StatusBaseText {
                    id: keyText
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 21
                    anchors.right: parent.right
                    anchors.rightMargin: 21
                    width: Math.min(implicitWidth, 200)

                    color: Theme.palette.dangerColor1
                    font.pixelSize: 15
                    lineHeight: 22
                    lineHeightMode: Text.FixedHeight
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                    text: root.store.walletModelV2Inst.settingsView.signingPhrase
                }
            }
            Rectangle {
                id: infoRect
                color: Theme.palette.baseColor5
                width: parent.width - keyRect.width
                height: Math.max(keyText.implicitHeight, infoText.implicitHeight) + 42
                StatusBaseText {
                    id: infoText
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 25
                    width: 366

                    color: Theme.palette.directColor4
                    font.pixelSize: 12
                    lineHeight: 16
                    lineHeightMode: Text.FixedHeight
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                    text: qsTr("If you see something different, you should immediately sign out and reinstall Status")
                }
            }
        }
    }

    BackupSeedModal {
        id: backupSeedModal
    }
}
