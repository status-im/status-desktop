import QtQuick 2.15
import QtQuick.Layouts 1.14

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Popups 0.1

import AppLayouts.Communities.controls 1.0
import AppLayouts.Communities.helpers 1.0
import AppLayouts.Communities.panels 1.0
import AppLayouts.Wallet.controls 1.0
import utils 1.0

import SortFilterProxyModel 0.2

StatusScrollView {
    id: root

    property int viewWidth: 560 // by design

    // Community info:
    property string communityName
    property url communityLogo
    property color communityColor

    // Network related properties:
    property var layer1Networks
    property var layer2Networks
    property var enabledNetworks
    property var allNetworks

    // Wallet account expected roles: address, name, color, emoji, walletType
    property var accounts

    property string feeText
    property string feeErrorText
    property bool isFeeLoading

    // Privileged tokens:
    readonly property TokenObject ownerToken: TokenObject {
        name: PermissionsHelpers.ownerTokenNameTag + root.communityName
        type: Constants.TokenType.ERC721
        privilegesLevel: Constants.TokenPrivilegesLevel.Owner
        artworkSource: root.communityLogo
        color: root.communityColor
        symbol: PermissionsHelpers.communityNameToSymbol(true, root.communityName)
        transferable: true
        remotelyDestruct: false
        supply: "1"
        infiniteSupply: false
        description: qsTr("This is the %1 Owner token. The hodler of this collectible has ultimate control over %1 Community token administration.").arg(root.communityName)
    }
    readonly property TokenObject tMasterToken: TokenObject {
        name: PermissionsHelpers.tMasterTokenNameTag + root.communityName
        type: Constants.TokenType.ERC721
        privilegesLevel: Constants.TokenPrivilegesLevel.TMaster
        artworkSource: root.communityLogo
        color: root.communityColor
        symbol: PermissionsHelpers.communityNameToSymbol(false, root.communityName)
        remotelyDestruct: true
        description: qsTr("This is the %1 TokenMaster token. The hodler of this collectible has full admin rights for the %1 Community in Status and can mint and airdrop %1 Community tokens.").arg(root.communityName)
    }

    readonly property string feeLabel:
        qsTr("Mint %1 Owner and TokenMaster tokens on %2")
        .arg(communityName).arg(ownerToken.chainName)

    signal mintClicked

    QtObject {
        id: d

        readonly property int titleSize: 17
        readonly property int iconSize: 20
    }

    padding: 0
    contentWidth: mainLayout.width
    contentHeight: mainLayout.height

    Component.onCompleted: networkSelector.setChain(ownerToken.chainId)

    ColumnLayout {
        id: mainLayout

        width: root.viewWidth
        spacing: Style.current.padding

        // Owner token defintion:
        StatusBaseText {
            Layout.maximumWidth: root.viewWidth

            elide: Text.ElideMiddle
            font.pixelSize: d.titleSize
            font.bold: true

            text: ownerToken.name
        }

        TokenInfoPanel {
            Layout.fillWidth: true

            token: root.ownerToken
            accountBoxVisible: false
            networkBoxVisible: false
        }

        StatusModalDivider {
            Layout.fillWidth: true

            topPadding: Style.current.padding
            bottomPadding: Style.current.padding
        }

        // TMaster token definition:
        StatusBaseText {
            Layout.maximumWidth: root.viewWidth

            elide: Text.ElideMiddle
            font.pixelSize: d.titleSize
            font.bold: true

            text: tMasterToken.name
        }

        TokenInfoPanel {
            Layout.fillWidth: true

            token: root.tMasterToken
            accountBoxVisible: false
            networkBoxVisible: false
        }

        StatusModalDivider {
            Layout.fillWidth: true

            topPadding: Style.current.padding
            bottomPadding: Style.current.padding
        }

        CustomLabelDescriptionComponent {
            label: qsTr("Select account")
            description: qsTr("This account will be where you receive your Owner token and will also be the account that pays the token minting gas fees.")
        }

        ColumnLayout {
            spacing: 11

            AccountSelector {
                id: accountBox

                readonly property string address: {
                    root.accounts.count
                    return SQUtils.ModelUtils.get(root.accounts, currentIndex, "address")
                }

                readonly property string initAccountName: ownerToken.accountName
                readonly property int initIndex: {
                    root.accounts.count
                    return SQUtils.ModelUtils.indexOf(root.accounts, "name", initAccountName)
                }

                Layout.fillWidth: true
                Layout.topMargin: -Style.current.halfPadding

                currentIndex: (initIndex !== -1) ? initIndex : 0
                model: root.accounts

                onAddressChanged: {
                    ownerToken.accountAddress = address
                    tMasterToken.accountAddress = address
                }
                control.onDisplayTextChanged: {
                    ownerToken.accountName = control.displayText
                    tMasterToken.accountName = control.displayText
                }
            }

            StatusBaseText {
                Layout.fillWidth: true

                visible: !!root.feeErrorText
                horizontalAlignment: Text.AlignRight

                font.pixelSize: Theme.tertiaryTextFontSize
                color: Theme.palette.dangerColor1
                text: root.feeErrorText
                wrapMode: Text.Wrap
            }
        }

        CustomNetworkFilterRowComponent {
            id: networkSelector

            label: qsTr("Select network")
            description: qsTr("The network you select will be where all your community’s tokens reside. Once set, this setting can’t be changed and tokens can’t move to other networks.")
        }

        FeesBox {
            Layout.fillWidth: true
            Layout.topMargin: Style.current.padding

            model: QtObject {
                id: singleFeeModel

                readonly property string title: root.feeLabel
                readonly property string feeText: root.isFeeLoading ?
                                                      "" : root.feeText
                readonly property bool error: root.feeErrorText !== ""
            }

            showAccountsSelector: false
        }

        StatusButton {
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.topMargin: 4
            Layout.bottomMargin: Style.current.padding

            enabled: root.feeText && !root.feeErrorText
            text: qsTr("Mint")

            onClicked: root.mintClicked()
        }
    }

    component CustomLabelDescriptionComponent: ColumnLayout {
        id: labelDescComponent

        property string label
        property string description

        Layout.fillWidth: true

        StatusBaseText {
            text: labelDescComponent.label
            color: Theme.palette.directColor1
            font.pixelSize: Theme.primaryTextFontSize
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: labelDescComponent.description
            color: Theme.palette.baseColor1
            font.pixelSize: Theme.primaryTextFontSize
            lineHeight: 1.2
            wrapMode: Text.WordWrap
        }
    }

    component CustomNetworkFilterRowComponent: ColumnLayout {
        id: networkComponent

        property string label
        property string description

        function setChain(chainId) { netFilter.setChain(chainId) }

        readonly property alias currentNetworkName: netFilter.currentValue

        Layout.fillWidth: true
        Layout.topMargin: Style.current.padding
        spacing: 8

        CustomLabelDescriptionComponent {
            label: networkComponent.label
            description: networkComponent.description
        }

        NetworkFilter {
            id: netFilter

            Layout.fillWidth: true

            allNetworks: root.allNetworks
            layer1Networks: root.layer1Networks
            layer2Networks: root.layer2Networks
            enabledNetworks: root.enabledNetworks
            multiSelection: false
            control.topPadding: 10
            control.background: Rectangle {
                height: 44
                radius: 8
                color: "transparent"
                border.color: Theme.palette.directColor7
            }

            onToggleNetwork: (network) => {
                // Set Owner Token network properties:
                ownerToken.chainId = network.chainId
                ownerToken.chainName = network.chainName
                ownerToken.chainIcon = network.iconUrl

                // Set TMaster Token network properties:
                tMasterToken.chainId = network.chainId
                tMasterToken.chainName = network.chainName
                tMasterToken.chainIcon = network.iconUrl
            }
        }
    }
}
