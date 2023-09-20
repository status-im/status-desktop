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

    function resetView() {
        searchBox.reset()
    }

    contentItem: ColumnLayout {
        spacing: 12

        MenuBackButton {
            id: backButton
            Layout.fillWidth: true
            onClicked: {
                close()
                back()
            }
        }

        SearchBox {
            id: searchBox

            property string searchValue: ""

            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            font.pixelSize: 13
            placeholderFont.pixelSize: font.pixelSize
            input.height: 36
            placeholderText: qsTr("Search name, ENS or address")
            onTextChanged: searchTimer.restart()

            // Used to optimize the search when writing word
            Timer {
               id: searchTimer
               interval: 750
               onTriggered: searchBox.searchValue = searchBox.text
            }
        }

        StatusSwitchTabBar {
            id: tabBar
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            StatusSwitchTabButton {
                text: qsTr("Recent")
            }
            StatusSwitchTabButton {
                text: qsTr("Saved")
            }
        }

        StackLayout {
            id: layout
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex

            ColumnLayout {
                id: column1
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0
                ButtonGroup {
                    id: recentsButtonGroup
                    exclusive: false
                }
                StatusBaseText {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("No Recents")
                    visible: recipientsListView.count === 0 && !root.loadingRecipients
                }
                StatusBaseText {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Loading Recents")
                    visible: root.loadingRecipients
                }
                StatusListView {
                    id: recipientsListView
                    visible: !root.loadingRecipients
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: SortFilterProxyModel {
                        sourceModel: root.recentsList
                        filters: ExpressionFilter {
                            enabled: root.recentsList.count > 0 && layout.currentIndex === 0
                            expression: {
                                const searchValue = searchBox.searchValue
                                if (!searchValue)
                                    return true
                                const address = model.address.toLowerCase()
                                return address.startsWith(searchValue) || store.getNameForAddress(address).toLowerCase().indexOf(searchValue) !== -1
                            }
                        }
                    }

                    reuseItems: true
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
                        assetSettings.width: !!name ? 32 : 16
                        assetSettings.height: !!name ? 32 : 16
                        buttonGroup: recentsButtonGroup
                        allChecked: root.allRecentsChecked
                        checked: root.allRecentsChecked ? true : root.recentsFilters.includes(model.address)
                        onActionTriggered: root.recentsToggled(model.address)
                    }
                }
            }

            ColumnLayout {
                id: column2
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0
                ButtonGroup {
                    id: savedButtonGroup
                    exclusive: false
                }
                StatusBaseText {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("No Saved Address")
                    visible: savedAddressesListView.count === 0
                }
                StatusListView {
                    id: savedAddressesListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: SortFilterProxyModel {
                        sourceModel: root.savedAddressList
                        filters: ExpressionFilter {
                            enabled: root.savedAddressList.count > 0 && layout.currentIndex === 1
                            expression: {
                                const searchValue = searchBox.searchValue
                                if (!searchValue)
                                    return true
                                return model.name.toLowerCase().indexOf(searchValue) !== -1
                                       || model.address.toLowerCase().startsWith(searchValue)
                                       || model.ens.toLowerCase().startsWith(searchValue)
                            }
                        }
                    }
                    delegate: ActivityTypeCheckBox {
                        width: ListView.view.width
                        height: 44
                        title: model.name ?? ""
                        subTitle: {
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
                        assetSettings.bgHeight: 32
                        assetSettings.bgWidth: 32
                        assetSettings.width: 32
                        assetSettings.height: 32
                        buttonGroup: savedButtonGroup
                        allChecked: root.allSavedAddressesChecked
                        checked: root.allSavedAddressesChecked ? true : root.savedAddressFilters.includes(model.address)
                        onActionTriggered: root.savedAddressToggled(model.address)
                    }
                }
            }
        }
    }
}
