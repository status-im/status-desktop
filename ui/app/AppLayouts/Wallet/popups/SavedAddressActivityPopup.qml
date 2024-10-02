import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import AppLayouts.stores 1.0
import AppLayouts.Profile.stores 1.0 as ProfileStores
import AppLayouts.Wallet.stores 1.0 as WalletStore

import utils 1.0
import shared.views 1.0
import shared.stores 1.0 as SharedStores

import "../controls"
import ".."

StatusModal {
    id: root

    property SharedStores.NetworkConnectionStore networkConnectionStore
    property ProfileStores.ContactsStore contactsStore
    property var sendModalPopup

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    hasCloseButton: false

    width: d.popupWidth
    contentHeight: content.height

    onClosed: {
        root.close()
        walletSection.activityController.setFilterToAddresses(JSON.stringify([]))
        walletSection.activityController.updateFilter()
    }

    function initWithParams(params = {}) {
        d.name = params.name?? ""
        d.address = params.address?? Constants.zeroAddress
        d.ens = params.ens?? ""
        d.colorId = params.colorId?? ""
        d.chainShortNames = params.chainShortNames?? ""

        walletSection.activityController.setFilterToAddresses(JSON.stringify([d.address]))
        walletSection.activityController.updateFilter()
    }

    QtObject {
        id: d

        readonly property int popupWidth: 477
        readonly property int popupHeight: 672
        readonly property int contentWidth: d.popupWidth - 2 * d.margin
        readonly property int margin: 24
        readonly property int radius: 8

        property string name: ""
        property string address: Constants.zeroAddress
        property string ens: ""
        property string colorId: ""
        property string chainShortNames: ""

        readonly property string visibleAddress: !!d.ens? d.ens : d.address

        readonly property int yRange: historyView.firstItemOffset
        readonly property real extendedViewOpacity: {
            if (historyView.yPosition <= 0) {
                return 1
            }

            let op = 1 - historyView.yPosition / d.yRange
            if (op > 0) {
                return op
            }

            return 0
        }
        readonly property bool showSplitLine: d.extendedViewOpacity === 0
    }

    component Spacer: Item {
        width: 1
    }

    showFooter: false
    showHeader: false

    Rectangle {
        id: content
        width: d.popupWidth
        height: d.popupHeight
        color: Theme.palette.statusModal.backgroundColor
        radius: d.radius

        Item {
            id: fixedHeader
            anchors.top: parent.top
            anchors.left: parent.left
            implicitWidth: parent.width
            implicitHeight: childrenRect.height

            Column {
                anchors.top: parent.top
                width: parent.width

                Spacer {
                    height: 24
                }

                SavedAddressesDelegate {
                    id: savedAddress

                    implicitHeight: 72
                    implicitWidth: d.contentWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    leftPadding: 0
                    border.color: "transparent"

                    usage: SavedAddressesDelegate.Usage.Item
                    showButtons: true
                    statusListItemComponentsSlot.spacing: 4

                    statusListItemSubTitle.visible: d.extendedViewOpacity !== 1
                    statusListItemSubTitle.opacity: 1 - d.extendedViewOpacity
                    statusListItemSubTitle.customColor: Theme.palette.directColor1
                    statusListItemSubTitle.text: {
                        if (statusListItemSubTitle.visible) {
                            if (!!d.ens) {
                                return d.ens
                            }
                            else {
                                return WalletUtils.colorizedChainPrefix(d.chainShortNames) + Utils.richColorText(StatusQUtils.Utils.elideText(d.address,6,4), Theme.palette.directColor1)
                            }
                        }
                        return ""
                    }

                    sendButton.visible: d.extendedViewOpacity !== 1
                    sendButton.opacity: 1 - d.extendedViewOpacity
                    sendButton.type: StatusRoundButton.Type.Primary

                    asset.width: 72
                    asset.height: 72
                    asset.letterSize: 32
                    bgColor: Theme.palette.statusListItem.backgroundColor

                    networkConnectionStore: root.networkConnectionStore

                    name: d.name
                    address: d.address
                    chainShortNames: d.chainShortNames
                    ens: d.ens
                    colorId: d.colorId

                    statusListItemTitle.font.pixelSize: 22
                    statusListItemTitle.font.bold: Font.Bold

                    areTestNetworksEnabled: WalletStore.RootStore.areTestNetworksEnabled
                    isGoerliEnabled: WalletStore.RootStore.isGoerliEnabled

                    onAboutToOpenPopup: {
                        root.close()
                    }
                    onOpenSendModal: {
                        root.close()
                        root.sendModalPopup.open(recipient)
                    }
                }

                Spacer {
                    height: 20
                }

                Rectangle {
                    width: parent.width
                    height: 4
                    opacity: 0.5
                    color: d.showSplitLine? Style.current.separator : "transparent"
                }
            }
        }

        Item {
            id: extendedView
            anchors.top: fixedHeader.bottom
            anchors.left: parent.left
            implicitWidth: parent.width
            implicitHeight: childrenRect.height
            z: d.extendedViewOpacity === 1? 1 : 0

            Column {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: d.contentWidth

                Rectangle {
                    opacity: d.extendedViewOpacity
                    width: parent.width
                    height: Math.max(addressText.height, copyButton.height) + 24
                    color: "transparent"
                    radius: d.radius
                    border.color: Theme.palette.baseColor5
                    border.width: 1

                    StatusBaseText {
                        id: addressText
                        anchors.left: parent.left
                        anchors.right: copyButton.left
                        anchors.rightMargin: Style.current.padding
                        anchors.leftMargin: Style.current.padding
                        anchors.verticalCenter: parent.verticalCenter
                        text: !!d.ens? d.ens : WalletUtils.colorizedChainPrefix(d.chainShortNames) + d.address
                        wrapMode: Text.WrapAnywhere
                        font.pixelSize: 15
                        color: Theme.palette.directColor1
                    }

                    StatusRoundButton {
                        id: copyButton
                        width: 24
                        height: 24
                        anchors.right: parent.right
                        anchors.rightMargin: Style.current.padding
                        anchors.top: addressText.top
                        icon.name: "copy"
                        type: StatusRoundButton.Type.Tertiary
                        onClicked: ClipboardUtils.setText(d.visibleAddress)
                    }
                }

                Spacer {
                    height: 16
                }

                StatusButton {
                    opacity: d.extendedViewOpacity
                    width: parent.width
                    radius: d.radius
                    text: qsTr("Send")
                    icon.name: "send"
                    enabled: root.networkConnectionStore.sendBuyBridgeEnabled
                    onClicked: {
                        root.close()
                        root.sendModalPopup.open(d.visibleAddress)
                    }
                }

                Spacer {
                    height: 32
                }
            }
        }

        HistoryView {
            id: historyView
            anchors.top: fixedHeader.bottom
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: d.margin
            width: parent.width - 2 * d.margin

            disableShadowOnScroll: true
            hideVerticalScrollbar: true
            displayValues: false
            firstItemOffset: extendedView.height
            overview: ({
                           isWatchOnlyAccount: false,
                           mixedcaseAddress: d.address
                       })
            walletRootStore: WalletStore.RootStore
        }
    }
}
