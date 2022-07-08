import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0

import shared.controls 1.0

import "../stores"

StatusModal {
    id: popup

    property var selectedAccount
    property string networkPrefix: ""
    property string completeAddressWithNetworkPrefix

    onSelectedAccountChanged: {
        if (selectedAccount.address) {
            txtWalletAddress.text = selectedAccount.address
        }
    }

    onCompleteAddressWithNetworkPrefixChanged: {
        qrCodeImage.source = RootStore.getQrCode(completeAddressWithNetworkPrefix)
    }

    header.title: qsTr("Receive")
    contentHeight: layout.implicitHeight
    width: 556

    showHeader: false
    showAdvancedHeader: true

    hasFloatingButtons: true
    advancedHeaderComponent: StatusFloatingButtonsSelector {
        id: floatingHeader
        model: RootStore.accounts
        delegate: Rectangle {
            width: button.width
            height: button.height
            radius: 8
            visible: floatingHeader.visibleIndices.includes(index)
            StatusButton {
                id: button
                topPadding: 8
                bottomPadding: 0
                implicitHeight: 32
                defaultLeftPadding: 4
                text: name
                icon.emoji: !!emoji ? emoji: ""
                icon.emojiSize: Emoji.size.middle
                icon.name: !emoji ? "filled-account": ""
                normalColor: "transparent"
                highlighted: index === floatingHeader.currentIndex
                onClicked: {
                    popup.selectedAccount =  model
                    floatingHeader.currentIndex = index
                }
                Component.onCompleted: {
                    // On startup make the preseected wallet in the floating menu
                    if(name === popup.selectedAccount.name)
                        floatingHeader.currentIndex = index
                }
            }
        }
        popupMenuDelegate: StatusListItem {
            implicitWidth: 272
            title: name
            subTitle: currencyBalance
            icon.emoji: !!emoji ? emoji: ""
            icon.color: model.color
            icon.name: !emoji ? "filled-account": ""
            icon.letterSize: 14
            icon.isLetterIdenticon: !!model.emoji
            icon.background.color: Theme.palette.indirectColor1
            onClicked: {
                popup.selectedAccount =  model
                floatingHeader.itemSelected(index)
            }
            visible: !floatingHeader.visibleIndices.includes(index)
        }
    }

    contentItem: Column {
        id: layout
        width: popup.width

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

                anchors.centerIn: parent
                anchors.horizontalCenterOffset: need2Columns ? 0 : qrCodeBox.width/2 + Style.current.xlPadding + Style.current.halfPadding
                height: qrCodeBox.height

                columnSpacing: need2Columns ? qrCodeBox.width + Style.current.bigPadding : 0
                flow: Grid.TopToBottom
                columns: need2Columns ? 2 : 1
                spacing: 5
                Repeater {
                    model: RootStore.enabledNetworks
                    delegate: StatusListItemTag {
                        image.source: Style.png(iconUrl)
                        title: shortName
                        titleText.color: chainColor
                        closeButtonVisible: false
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: selectPopup.open()
                        }
                    }
                }
                StatusListItemTag {
                    closeButtonVisible: false
                    icon.name: "edit_pencil"
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            selectPopup.open()
                        }
                    }
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
                        source: Style.svg("status-logo-icon")
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
                        model: RootStore.enabledNetworks
                        delegate: StatusBaseText {
                            font.pixelSize: 15
                            color: chainColor
                            text: shortName + ":"
                            Component.onCompleted: {
                                if(index === 0)
                                    popup.networkPrefix = ""
                                popup.networkPrefix +=text
                            }
                        }
                    }
                }
                StatusAddress {
                    id: txtWalletAddress
                    color: Theme.palette.directColor1
                    font.pixelSize: 15
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
                    store: RootStore
                    textToCopy: txtWalletAddress.text
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
            x: multiChainList.x + Style.current.xlPadding + Style.current.halfPadding
            y: centralLayout.y
            layer1Networks: RootStore.layer1Networks
            layer2Networks: RootStore.layer2Networks
            testNetworks: RootStore.testNetworks
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            onToggleNetwork: {
                RootStore.toggleNetwork(chainId)
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
                    target: popup
                    completeAddressWithNetworkPrefix: popup.selectedAccount.address
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
                    textToCopy: popup.networkPrefix + txtWalletAddress.text
                }
                PropertyChanges {
                    target: popup
                    completeAddressWithNetworkPrefix: popup.networkPrefix + popup.selectedAccount.address
                }
            }
        ]
    }
}

