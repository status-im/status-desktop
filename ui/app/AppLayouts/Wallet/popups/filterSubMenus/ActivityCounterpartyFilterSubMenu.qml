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
    property bool loadingRecipients: false
    property var recentsFilters
    readonly property bool allRecentsChecked: recentsFilters.length === 0

    property var savedAddressList
    property var savedAddressFilters
    readonly property bool allSavedAddressesChecked: savedAddressFilters.length === 0

    signal back()
    signal savedAddressToggled(string address)
    signal recentsToggled(string address)
    signal updateRecipientsModel()

    implicitWidth: 289

    Component.onCompleted: root.updateRecipientsModel()

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
            StatusBaseText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("No Recents")
                visible: root.recentsList.count === 0 && !root.loadingRecipients
            }
            StatusBaseText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Loading Recents")
                visible: root.loadingRecipients
            }
            StatusListView {
                visible: !root.loadingRecipients
                width: parent.width
                height: root.height - tabBar.height - 12
                model: root.recentsList
                delegate: ActivityTypeCheckBox {
                    readonly property string name: store.getNameForAddress(model.address)
                    width: ListView.view.width
                    height: 44
                    title: name || StatusQUtils.Utils.elideText(model.address,6,4)
                    subTitle: name ? StatusQUtils.Utils.elideText(model.address,6,4): ""
                    statusListItemSubTitle.elide: Text.ElideMiddle
                    statusListItemSubTitle.wrapMode: Text.NoWrap
                    assetSettings.name: name || "address"
                    assetSettings.isLetterIdenticon: !!name
                    assetSettings.bgHeight: 32
                    assetSettings.bgWidth: 32
                    assetSettings.bgRadius: assetSettings.bgHeight/2
                    assetSettings.width: 16
                    assetSettings.height: 16
                    buttonGroup: recentsButtonGroup
                    allChecked: root.allRecentsChecked
                    checked: root.allRecentsChecked ? true : root.recentsFilters.includes(model.address)
                    onActionTriggered: root.recentsToggled(model.address)
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
            StatusBaseText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("No Saved Address")
                visible: root.savedAddressList.count === 0
            }
            StatusListView {
                width: parent.width
                height: root.height - tabBar.height - 12
                model: root.savedAddressList
                delegate: ActivityTypeCheckBox {
                    width: ListView.view.width
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
