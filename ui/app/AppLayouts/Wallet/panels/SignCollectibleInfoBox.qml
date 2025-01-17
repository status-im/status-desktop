import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0

import AppLayouts.Wallet.views.collectibles 1.0

Control {
    id: root

    /** Input property holding collectible name **/
    required property string name
    /** Input property holding collectible background color **/
    required property color backgroundColor
    /** Input property holding if collectible has valid metadata **/
    required property bool isMetadataValid
    /** Input property holding collectible fallback image url **/
    required property string fallbackImageUrl
    /** Input property holding collectible contract address **/
    required property string contractAddress
    /** Input property holding collectible tokenId **/
    required property string tokenId
    /** Input property holding if collectible is loading **/
    required property bool loading

    /** Input property holding network short name **/
    required property string networkShortName
    /** Input property holding network explorer url **/
    required property string networkBlockExplorerUrl

    /** Input property holding openSea explorer url **/
    required property string openSeaExplorerUrl

    /** Signal to launch link **/
    signal openLink(string link)

    QtObject {
        id: d

        function getExplorerName() {
            return Utils.getChainExplorerName(root.networkShortName)
        }

        readonly property string collectibleBlockExplorerLink: {
            if (root.networkShortName === Constants.networkShortChainNames.mainnet) {
                return "%1/nft/%2/%3".arg(root.networkBlockExplorerUrl).arg(root.contractAddress).arg(root.tokenId)
            }
            else {
                return "%1/token/%2?a=%3".arg(root.networkBlockExplorerUrl).arg(root.contractAddress).arg(root.tokenId)
            }
        }
    }

    padding: Theme.smallPadding

    background: Rectangle {
        color: moreButton.hovered
               ? Theme.palette.statusMenu.hoverBackgroundColor
               : "transparent"

        radius: 8
        border.width: 1
        border.color: Theme.palette.baseColor2
    }

    contentItem: StatusItemDelegate {
        contentItem: RowLayout {
            spacing: 12
            CollectibleMedia {
                id: collectibleMedia

                objectName: "collectibleMedia"
                backgroundColor: root.backgroundColor
                isMetadataValid: root.isMetadataValid
                fallbackImageUrl: root.fallbackImageUrl

                manualMaxDimension: 40
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: 4
                isCollectibleLoading: root.loading
            }

            ColumnLayout {
                spacing: 0
                StatusBaseText {
                    objectName: "primaryText"
                    text: !!root.name ?
                              root.name : ""
                    font.pixelSize: Theme.additionalTextSize
                    elide: Text.ElideRight
                }
                StatusBaseText {
                    objectName: "secondaryText"
                    text: !!root.tokenId ?
                              root.tokenId : ""
                    font.pixelSize: Theme.additionalTextSize
                    color: Theme.palette.baseColor1
                }
            }

            RowLayout {
                Layout.fillWidth: true
            }

            StatusFlatButton {
                id: moreButton

                objectName: "moreButton"
                width: 40
                height: 40
                icon.name: "more"
                icon.color: highlighted ? Theme.palette.directColor1 : Theme.palette.directColor5

                highlighted: moreMenu.opened
                onClicked: moreMenu.popup(moreButton, 0, height + 4)
            }
        }
    }

    StatusMenu {
        objectName: "moreMenu"
        id: moreMenu

        StatusAction {
            objectName: "openSeaExternalLink"
            text: qsTr("View collectible on OpenSea")
            icon.name: "external-link"
            onTriggered: {
                const link = "%1/%2/%3".arg(root.openSeaExplorerUrl).arg(root.contractAddress).arg(root.tokenId)
                root.openLink(link)
            }
        }
        StatusAction {
            objectName: "blockchainExternalLink"
            //: e.g. "View collectible on Etherscan"
            text:  qsTr("View collectible on %1").arg(d.getExplorerName())
            icon.name: "external-link"
            onTriggered: root.openLink(d.collectibleBlockExplorerLink)
        }
        StatusSuccessAction {
            objectName: "copyButton"
            text: qsTr("Copy %1 collectible address").arg(d.getExplorerName())
            successText: qsTr("Copied")
            icon.name: "copy"
            autoDismissMenu: true
            onTriggered: ClipboardUtils.setText(d.collectibleBlockExplorerLink)
        }
    }
}
