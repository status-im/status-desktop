import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.13

import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import shared.controls 1.0

import SortFilterProxyModel 0.2

import utils 1.0

import "../../../Wallet"
import "../../controls"

StatusMenu {
    id: root

    property var store

    property var recentsList
    property var recentsFilters
    readonly property bool allRecentsChecked: recentsFilters.length === 0

    property var savedAddressList
    property var savedAddressFilters
    readonly property bool allSavedAddressesChecked: savedAddressFilters.length === 0

    signal back()
    signal savedAddressToggled(string address)
    signal recentsToggled(string address)

    implicitWidth: 289

    MenuBackButton {
        id: backButton
        width: parent.width
        onClicked: {
            close()
            back()
        }
    }

    StatusSwitchTabBar {
        id: tabBar
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: backButton.bottom
        anchors.topMargin: 12
        width: parent.width - 16
        StatusSwitchTabButton {
            text: qsTr("Recent")
        }
        StatusSwitchTabButton {
            text: qsTr("Saved")
        }
    }

    StackLayout {
        id: layout
        width: parent.width
        anchors.top: tabBar.bottom
        anchors.topMargin: 12
        currentIndex: tabBar.currentIndex

        Column {
            id: column1
            Layout.fillWidth: true
            spacing: 0
            ButtonGroup {
                id: recentsButtonGroup
                exclusive: false
            }
            Repeater {
                model: root.recentsList
                delegate: ActivityTypeCheckBox {
                    readonly property int transactionType: model.activityEntry.recipient.toLowerCase() === store.overview.mixedcaseAddress.toLowerCase() ? Constants.TransactionType.Receive : Constants.TransactionType.Send
                    readonly property string fromName: store.getNameForAddress(model.activityEntry.sender)
                    readonly property string toName: store.getNameForAddress(model.activityEntry.recipient)
                    width: parent.width
                    height: 44
                    title: transactionType === Constants.TransactionType.Receive ?
                               fromName || StatusQUtils.Utils.elideText(model.activityEntry.sender,6,4) :
                               toName || StatusQUtils.Utils.elideText(model.activityEntry.recipient,6,4)
                    subTitle: {
                        if (transactionType === Constants.TransactionType.Receive) {
                            return fromName ? StatusQUtils.Utils.elideText(model.activityEntry.sender,6,4) : ""
                        } else {
                            return toName ? StatusQUtils.Utils.elideText(model.activityEntry.recipient,6,4): ""
                        }
                    }
                    statusListItemSubTitle.elide: Text.ElideMiddle
                    statusListItemSubTitle.wrapMode: Text.NoWrap
                    assetSettings.name: (transactionType === Constants.TransactionType.Receive ? fromName : toName) || "address"
                    assetSettings.isLetterIdenticon: transactionType === Constants.TransactionType.Receive ? !!fromName  : !!toName
                    assetSettings.bgHeight: 32
                    assetSettings.bgWidth: 32
                    assetSettings.bgRadius: assetSettings.bgHeight/2
                    assetSettings.width: 16
                    assetSettings.height: 16
                    buttonGroup: recentsButtonGroup
                    allChecked: root.allRecentsChecked
                    checked: root.allRecentsChecked ? true : root.recentsFilters.includes(transactionType === Constants.TransactionType.Receive ? model.activityEntry.sender: model.activityEntry.recipient)
                    onActionTriggered: root.recentsToggled(transactionType === Constants.TransactionType.Receive ? model.activityEntry.sender: model.activityEntry.recipient)
                }
            }
        }

        Column {
            id: column2
            Layout.fillWidth: true
            spacing: 0
            ButtonGroup {
                id: savedButtonGroup
                exclusive: false
            }
            Repeater {
                model: root.savedAddressList
                delegate: ActivityTypeCheckBox {
                    width: parent.width
                    height: 44
                    title: model.name ?? ""
                    subTitle:  {
                        if (model.ens.length > 0) {
                            return sensor.containsMouse ? Utils.richColorText(model.ens, Theme.palette.directColor1) : model.ens
                        }
                        else {
                            let elidedAddress = StatusQUtils.Utils.elideText(model.address,6,4)
                            return sensor.containsMouse ? WalletUtils.colorizedChainPrefix(model.chainShortNames) + Utils.richColorText(elidedAddress, Theme.palette.directColor1): model.chainShortNames + elidedAddress
                        }
                    }
                    statusListItemSubTitle.elide: Text.ElideMiddle
                    statusListItemSubTitle.wrapMode: Text.NoWrap
                    assetSettings.name: model.name
                    assetSettings.isLetterIdenticon: true
                    buttonGroup: savedButtonGroup
                    allChecked: root.allSavedAddressesChecked
                    checked: root.allSavedAddressesChecked ? true : root.savedAddressFilters.includes(model.address)
                    onActionTriggered: root.savedAddressToggled(model.address)
                }
            }
        }
    }

}
