import QtQuick 2.13
import QtGraphicalEffects 1.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0

import shared.controls 1.0
import shared.popups 1.0

import SortFilterProxyModel 0.2

import AppLayouts.stores 1.0
import "../stores"

StatusModal {
    id: root

    QtObject {
        id: d
        property string selectedAccountAddress
        property string networkPrefix
        property string completeAddressWithNetworkPrefix
    }

    header.title: qsTr("Receive")
    contentHeight: layout.implicitHeight
    width: 556

    showHeader: false
    showAdvancedHeader: true

    hasFloatingButtons: true
    advancedHeaderComponent: AccountsModalHeader {
        id: header
        model: SortFilterProxyModel {
            sourceModel: RootStore.accounts
        }
        selectedIndex: RootStore.getUserSelectedAccountIndex(header.model)
        onSelectedIndexChanged: selectedAccount = header.model.get(header.selectedIndex)
        onSelectedAccountChanged: d.selectedAccountAddress = selectedAccount.address
        Connections {
            target: RootStore.accounts
            function onModelReset() {
                header.selectedAccount = header.model.get(header.selectedIndex)
            }
        }
    }

    contentItem: Column {
        id: layout
        width: root.width

        topPadding: Style.current.xlPadding
        spacing: Style.current.bigPadding

        StatusSwitchTabBar {
            id: tabBar
            anchors.horizontalCenter: parent.horizontalCenter
            StatusSwitchTabButton {
                text: qsTr("Legacy")
            }
            StatusSwitchTabButton {
                text: qsTr("Multichain")
            }
        }

        Item {
            width: parent.width
            height: qrCodeBox.height
            id: centralLayout

            Grid {
                id: multiChainList
                property bool need2Columns: RootStore.enabledNetworks.count >= 9

                anchors.left: need2Columns ? undefined: qrCodeBox.right
                anchors.leftMargin: need2Columns ?undefined : Style.current.halfPadding
                anchors.centerIn: need2Columns ? parent : undefined
                height: qrCodeBox.height

                columnSpacing: need2Columns ? qrCodeBox.width + Style.current.bigPadding : 0
                flow: Grid.TopToBottom
                columns: need2Columns ? 2 : 1
                spacing: 5
                property var networkProxies: [layer1NetworksClone, layer2NetworksClone]
                Repeater {
                    model: multiChainList.networkProxies.length
                    delegate: Repeater {
                        model: multiChainList.networkProxies[index]
                        delegate: InformationTag {
                            tagPrimaryLabel.text: model.shortName
                            tagPrimaryLabel.color: model.chainColor
                            image.source: Style.svg("tiny/" + model.iconUrl)
                            visible: model.isEnabled
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: selectPopup.open()
                            }
                        }
                    }
                }
                StatusRoundButton {
                    id: editButton
                    width: 32
                    height: 32
                    icon.name: "edit_pencil"
                    color: Theme.palette.primaryColor3
                    onClicked: selectPopup.open()
                }
            }

            Rectangle {
                id: qrCodeBox
                height: 339
                width: 339
                anchors.centerIn: parent
                anchors.horizontalCenter: parent.horizontalCenter
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Item {
                        width: qrCodeBox.width
                        height: qrCodeBox.height
                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            width: qrCodeBox.width
                            height: qrCodeBox.height
                            radius: Style.current.bigPadding
                            border.width: 1
                            border.color: Style.current.border
                        }
                        Rectangle {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            width: Style.current.bigPadding
                            height: Style.current.bigPadding
                        }
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            width: Style.current.bigPadding
                            height: Style.current.bigPadding
                        }
                    }
                }

                Image {
                    id: qrCodeImage
                    anchors.centerIn: parent
                    height: parent.height
                    width: parent.width
                    asynchronous: true
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    smooth: false
                    source: RootStore.getQrCode(d.completeAddressWithNetworkPrefix)
                }

                Rectangle {
                    anchors.centerIn: qrCodeImage
                    width: 78
                    height: 78
                    color: "white"
                    StatusIcon {
                        anchors.centerIn: parent
                        anchors.margins: 2
                        width: 78
                        height: 78
                        icon: "status-logo-icon"
                    }
                }
            }
        }

        Item  {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: addressLabel.height + copyButton.height
            Column {
                id: addressLabel
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Style.current.bigPadding
                StatusBaseText {
                    id: contactsLabel
                    font.pixelSize: 15
                    color: Theme.palette.baseColor1
                    text: qsTr("Your Address")
                }
                RowLayout {
                    id: networksLabel
                    spacing: -1
                    Repeater {
                        model: multiChainList.networkProxies.length
                        delegate: Repeater {
                            model: multiChainList.networkProxies[index]
                            delegate: StatusBaseText {
                                font.pixelSize: 15
                                color: chainColor
                                text: shortName + ":"
                                visible: model.isEnabled
                                onVisibleChanged: {
                                    if (visible) {
                                        d.networkPrefix += text
                                    } else {
                                        d.networkPrefix = d.networkPrefix.replace(text, "")
                                    }
                                }
                            }
                        }
                    }
                }
                StatusAddress {
                    id: txtWalletAddress
                    color: Theme.palette.directColor1
                    font.pixelSize: 15
                    text: d.selectedAccountAddress
                }
            }
            Column {
                id: copyButton
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Style.current.bigPadding
                spacing: 5
                CopyToClipBoardButton {
                    id: copyToClipBoard
                    textToCopy: txtWalletAddress.text
                    onCopyClicked: RootStore.copyToClipboard(textToCopy)
                }
                StatusBaseText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 13
                    color: Theme.palette.primaryColor1
                    text: qsTr("Copy")
                }
            }
        }

        NetworkSelectPopup {
            id: selectPopup

            x: multiChainList.x + editButton.width + 9
            y: tabBar.y + tabBar.height

            layer1Networks: layer1NetworksClone
            layer2Networks: layer2NetworksClone

            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            onToggleNetwork: (network, networkModel, index) => {
                network.isEnabled = !network.isEnabled
            }

            CloneModel {
                id: layer1NetworksClone

                sourceModel: RootStore.layer1Networks
                roles: ["layer", "chainId", "chainColor", "chainName","shortName", "iconUrl", "isEnabled"]
                // rowData used to clone returns string. Convert it to bool for bool arithmetics
                rolesOverride: [{
                    role: "isEnabled",
                    transform: (modelData) => Boolean(modelData.isEnabled)
                }]
            }

            CloneModel {
                id: layer2NetworksClone

                sourceModel: RootStore.layer2Networks
                roles: layer1NetworksClone.roles
                rolesOverride: layer1NetworksClone.rolesOverride
            }
        }

        states: [
            State {
                name: "legacy"
                when: tabBar.currentIndex === 0
                PropertyChanges {
                    target: multiChainList
                    visible: false
                }
                PropertyChanges {
                    target: contactsLabel
                    visible: true
                }
                PropertyChanges {
                    target: networksLabel
                    visible: false
                }
                PropertyChanges {
                    target: copyToClipBoard
                    textToCopy: txtWalletAddress.text
                }
                PropertyChanges {
                    target: d
                    completeAddressWithNetworkPrefix: d.selectedAccountAddress
                }
            },
            State {
                name: "multichain"
                when: tabBar.currentIndex === 1
                PropertyChanges {
                    target: multiChainList
                    visible: true
                }
                PropertyChanges {
                    target: contactsLabel
                    visible: false
                }
                PropertyChanges {
                    target: networksLabel
                    visible: true
                }
                PropertyChanges {
                    target: copyToClipBoard
                    textToCopy: d.networkPrefix + txtWalletAddress.text
                }
                PropertyChanges {
                    target: d
                    completeAddressWithNetworkPrefix: d.networkPrefix + d.selectedAccountAddress
                }
            }
        ]
    }
}

