import QtQuick 2.15
import QtQuick.Controls 2.15
import QtTest 1.15
import QtQml 2.15

import Models 1.0

import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Core.Theme 0.1

import AppLayouts.Wallet.popups.simpleSend 1.0

import utils 1.0

Item {
    id: root
    width: 600
    height: 400

    Component {
        id: componentUnderTest
        SendSignModal {
            anchors.centerIn: parent

            formatBigNumber: (number, symbol, noSymbolOption) => parseFloat(number).toLocaleString(Qt.locale(), 'f', 2) + (noSymbolOption ? "" : " " + symbol)

            tokenSymbol: "DAI"
            tokenAmount: "100.07"
            tokenContractAddress: "0x6B175474E89094C44Da98b954EedeAC495271d0F"

            accountName: "Hot wallet (generated)"
            accountAddress: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881"
            accountEmoji: "🚗"
            accountColor: Utils.getColorForId(Constants.walletAccountColors.primary)

            recipientAddress: "0xA858DDc0445d8131daC4d1DE01f834ffcbA52Ef1"

            networkShortName: Constants.networkShortChainNames.mainnet
            networkName: "Mainnet"
            networkIconPath: Theme.svg("network/Network=Ethereum")
            networkBlockExplorerUrl: "https://etherscan.io/"

            fiatFees: "1.54 EUR"
            cryptoFees: "0.001 ETH"
            estimatedTime: qsTr("> 5 minutes")

            loginType: Constants.LoginType.Password

            isCollectible: false
            collectibleContractAddress: ""
            collectibleTokenId: ""
            collectibleName: ""
            collectibleBackgroundColor: ""
            collectibleIsMetadataValid: false
            collectibleMediaUrl: ""
            collectibleMediaType: ""
            collectibleFallbackImageUrl: ""

            fnGetOpenSeaExplorerUrl: function(networkShortName) {
                return "%1/assets/%2".arg(Constants.openseaExplorerLinks.mainnetLink).arg(Constants.openseaExplorerLinks.ethereum)
            }
        }
    }

    SignalSpy {
        id: signalSpyAccepted
        target: controlUnderTest
        signalName: "accepted"
    }

    SignalSpy {
        id: signalSpyRejected
        target: controlUnderTest
        signalName: "rejected"
    }

    SignalSpy {
        id: signalSpyOpenLink
        target: Global
        signalName: "openLinkWithConfirmation"
    }

    property SendSignModal controlUnderTest: null

    TestCase {
        name: "SendSignModal"
        when: windowShown

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
            signalSpyAccepted.clear()
            signalSpyRejected.clear()
            signalSpyOpenLink.clear()
        }

        function test_basicGeometry() {
            verify(!!controlUnderTest)
            verify(controlUnderTest.width > 0)
            verify(controlUnderTest.height > 0)
        }

        function test_fromToProps() {
            verify(!!controlUnderTest)
            controlUnderTest.tokenSymbol = "DAI"
            controlUnderTest.tokenAmount = "1000.123456789"
            controlUnderTest.tokenContractAddress = "Oxdeadbeef"

            // title
            compare(controlUnderTest.title, qsTr("Sign Send"))

            // subtitle
            compare(controlUnderTest.subtitle, qsTr("%1 %2 to %3").arg(controlUnderTest.tokenAmount).arg(controlUnderTest.tokenSymbol)
                    .arg(SQUtils.Utils.elideAndFormatWalletAddress(controlUnderTest.recipientAddress)))

            compare(controlUnderTest.gradientColor, controlUnderTest.accountColor)

            // info tag
            compare(controlUnderTest.infoTagText, qsTr("Review all details before signing"))

            // info box
            const headerText = findChild(controlUnderTest.contentItem, "headerText")
            verify(!!headerText)
            compare(headerText.text, qsTr("Send %1 %2 to %3 on %4").
                    arg(controlUnderTest.tokenAmount).arg(controlUnderTest.tokenSymbol).
                    arg(SQUtils.Utils.elideAndFormatWalletAddress(controlUnderTest.recipientAddress)).arg(controlUnderTest.networkName))
            const fromImage = findChild(controlUnderTest.contentItem, "fromImageIdenticon")
            verify(!!fromImage)
            compare(fromImage.asset.name, "filled-account")
            compare(fromImage.asset.emoji, controlUnderTest.accountEmoji)
            compare(fromImage.asset.color, controlUnderTest.accountColor)
            compare(fromImage.asset.isLetterIdenticon, !!controlUnderTest.accountEmoji)

            const toImage = findChild(controlUnderTest.contentItem, "toImageIdenticon")
            verify(!!toImage)
            compare(toImage.asset.name, Constants.tokenIcon(controlUnderTest.tokenSymbol))

            // send box
            const sendBox = findChild(controlUnderTest.contentItem, "sendAssetBox")
            verify(!!sendBox)
            compare(sendBox.caption, qsTr("Send"))
            compare(sendBox.primaryText, "1000.123456789 DAI")
            compare(sendBox.secondaryText, SQUtils.Utils.elideAndFormatWalletAddress(controlUnderTest.tokenContractAddress))
        }

        function test_tokenContextmenu() {
            verify(!!controlUnderTest)

            controlUnderTest.open()

            // send box
            const sendBox = findChild(controlUnderTest.contentItem, "sendAssetBox")
            verify(!!sendBox)

            const contractInfoButtonWithMenu = findChild(sendBox, "contractInfoButtonWithMenu")
            verify(!!contractInfoButtonWithMenu)

            const contextMenu = findChild(contractInfoButtonWithMenu, "moreMenu")
            verify(!!contextMenu)
            verify(!contextMenu.opened)

            contractInfoButtonWithMenu.clicked(0)
            verify(contextMenu.opened)

            compare(contextMenu.contentModel.count, 2)

            const externalLink = findChild(contextMenu, "externalLink")
            verify(!!externalLink)
            compare(externalLink.text, !!controlUnderTest.tokenSymbol ?
                        qsTr("View %1 %2 contract address on %3").arg(controlUnderTest.networkName).arg(controlUnderTest.tokenSymbol).arg("Etherscan")
                      : qsTr("View %1 contract address on %2").arg(controlUnderTest.networkName).arg("Etherscan"))
            compare(externalLink.icon.name, "external-link")
            externalLink.triggered()
            tryCompare(signalSpyOpenLink, "count", 1)
            compare(signalSpyOpenLink.signalArguments[0][0],
                    "%1/%2/%3".arg(controlUnderTest.networkBlockExplorerUrl).arg(Constants.networkExplorerLinks.addressPath).arg(controlUnderTest.tokenContractAddress))
            verify(!contextMenu.opened)

            contractInfoButtonWithMenu.clicked(0)
            verify(contextMenu.opened)

            const copyButton = findChild(contextMenu, "copyButton")
            verify(!!copyButton)
            compare(copyButton.text, qsTr("Copy contract address"))
            compare(copyButton.icon.name, "copy")
            copyButton.triggered()
            verify(contextMenu.opened)
        }

        function test_collectible_data() {
            return [
                        {
                            contractAddress: "0x216b4b4ba9f3e719726886d34a177484278bfcae",
                            tokenId: "403",
                            name: "Punx not dead!",
                            backgroundColor: "ivory",
                            isMetadataValid: true,
                            mediaUrl: "https://i.seadn.io/gcs/files/4a875f997063f4f3772190852c1c44f0.png?w=128&auto=format",
                            mediaType: "image",
                            fallbackImageUrl: "https://i.seadn.io/gcs/files/4a875f997063f4f3772190852c1c44f0.png?w=128&auto=format"
                        },
                        {
                            contractAddress: "0x216b4b4ba9f3e719726886d34a177484278bfcae",
                            tokenId: "403",
                            name: "",
                            backgroundColor: "ivory",
                            isMetadataValid: true,
                            mediaUrl: "",
                            mediaType: "",
                            fallbackImageUrl: ""
                        }
                    ]
        }

        function test_collectible(data) {
            verify(!!controlUnderTest)
            controlUnderTest.open()

            verify(!controlUnderTest.isCollectible)

            const sendCollectibleBox = findChild(controlUnderTest.contentItem, "sendCollectibleBox")
            verify(!!sendCollectibleBox)
            verify(!sendCollectibleBox.visible)

            // send box
            const sendAssetBox = findChild(controlUnderTest.contentItem, "sendAssetBox")
            verify(!!sendAssetBox)
            verify(sendAssetBox.visible)

            controlUnderTest.isCollectible = true
            verify(sendCollectibleBox.visible)
            verify(!sendAssetBox.visible)
            controlUnderTest.collectibleContractAddress = data.contractAddress
            controlUnderTest.collectibleTokenId = data.tokenId
            controlUnderTest.collectibleName = data.name
            controlUnderTest.collectibleBackgroundColor = data.backgroundColor
            controlUnderTest.collectibleIsMetadataValid = data.isMetadataValid
            controlUnderTest.collectibleMediaUrl = data.mediaUrl
            controlUnderTest.collectibleMediaType = data.mediaType
            controlUnderTest.collectibleFallbackImageUrl = data.fallbackImageUrl

            // title
            compare(controlUnderTest.title, qsTr("Sign Send"))

            // subtitle
            compare(controlUnderTest.subtitle, qsTr("%1 to %2").arg(data.name)
                    .arg(SQUtils.Utils.elideAndFormatWalletAddress(controlUnderTest.recipientAddress)))

            compare(controlUnderTest.gradientColor, controlUnderTest.accountColor)

            // info tag
            compare(controlUnderTest.infoTagText, qsTr("Review all details before signing"))

            // info box
            const headerText = findChild(controlUnderTest.contentItem, "headerText")
            verify(!!headerText)
            compare(headerText.text, qsTr("Send %1 to %2 on %3").
                    arg(data.name).
                    arg(SQUtils.Utils.elideAndFormatWalletAddress(controlUnderTest.recipientAddress)).
                    arg(controlUnderTest.networkName))
            const collectibleMedia = findChild(controlUnderTest.contentItem, "collectibleMedia")
            verify(!!collectibleMedia)
            compare(collectibleMedia.width, 120)
            compare(collectibleMedia.height, 120)
            compare(collectibleMedia.radius, 12)
            compare(collectibleMedia.mediaUrl, data.mediaUrl)

            if(collectibleMedia.mediaUrl && !collectibleMedia.fallbackImageUrl) {
                const loadingErrorComponent = findChild(collectibleMedia, "loadingErrorComponent")
                verify(!!loadingErrorComponent)
                compare(loadingErrorComponent.icon, "help")
            }

            const loadingComponent = findChild(collectibleMedia, "loadingComponent")
            verify(!!loadingComponent)
            verify(loadingComponent.visible)

            const accountSmartIdenticon = findChild(controlUnderTest.contentItem, "accountSmartIdenticon")
            verify(!!accountSmartIdenticon)
            compare(accountSmartIdenticon.asset.name, "filled-account")
            compare(accountSmartIdenticon.asset.emoji, controlUnderTest.accountEmoji)
            compare(accountSmartIdenticon.asset.color, controlUnderTest.accountColor)
            compare(accountSmartIdenticon.asset.isLetterIdenticon, !!controlUnderTest.accountEmoji)

            // send collectible box
            const collectibleCaption = findChild(controlUnderTest.contentItem, "collectibleCaption")
            verify(!!collectibleCaption)
            compare(collectibleCaption.text, qsTr("Send"))
            const primaryText = findChild(sendCollectibleBox, "primaryText")
            verify(!!primaryText)
            compare(primaryText.text, !!data.name ? data.name: qsTr("Unknown"))
            const secondaryText = findChild(sendCollectibleBox, "secondaryText")
            verify(!!secondaryText)
            compare(secondaryText.text, data.tokenId)
            const smallCollectibleMedia = findChild(sendCollectibleBox, "collectibleMedia")
            verify(!!smallCollectibleMedia)
            compare(smallCollectibleMedia.width, 40)
            compare(smallCollectibleMedia.height, 40)
            compare(smallCollectibleMedia.radius, 4)
            compare(smallCollectibleMedia.mediaUrl, "")
            compare(smallCollectibleMedia.fallbackImageUrl, data.fallbackImageUrl)
            if(smallCollectibleMedia.mediaUrl && !smallCollectibleMedia.fallbackImageUrl) {
                const loadingErrorComponent = findChild(smallCollectibleMedia, "loadingErrorComponent")
                verify(!!loadingErrorComponent)
                compare(loadingErrorComponent.icon, "help")
            }

            // collectible context menu
            const moreMenu = findChild(sendCollectibleBox, "moreMenu")
            verify(!!moreMenu)

            const openSeaExternalLink = findChild(moreMenu, "openSeaExternalLink")
            verify(!!openSeaExternalLink)
            compare(openSeaExternalLink.text, qsTr("View collectible on OpenSea"))
            compare(openSeaExternalLink.icon.name, "external-link")
            openSeaExternalLink.triggered()
            tryCompare(signalSpyOpenLink, "count", 1)
            compare(signalSpyOpenLink.signalArguments[0][0],
                    "%1/%2/%3".arg(controlUnderTest.fnGetOpenSeaExplorerUrl(controlUnderTest.networkShortName)).
                    arg(data.contractAddress).arg(data.tokenId))

            const blockchainExternalLink = findChild(moreMenu, "blockchainExternalLink")
            verify(!!blockchainExternalLink)
            compare(blockchainExternalLink.text, qsTr("View collectible on Etherscan"))
            compare(blockchainExternalLink.icon.name, "external-link")
            blockchainExternalLink.triggered()
            tryCompare(signalSpyOpenLink, "count", 2)
            compare(signalSpyOpenLink.signalArguments[1][0],
                    "%1/nft/%2/%3".arg("https://etherscan.io/").arg(data.contractAddress).arg(data.tokenId))

            const copyButton = findChild(moreMenu, "copyButton")
            verify(!!copyButton)
            compare(copyButton.text, qsTr("Copy Etherscan collectible address"))
            compare(copyButton.icon.name, "copy")
        }

        function test_recpientInfo() {
            verify(!!controlUnderTest)

            // account box
            const recipientBox = findChild(controlUnderTest.contentItem, "recipientBox")
            verify(!!recipientBox)

            compare(recipientBox.caption, qsTr("To"))
            compare(recipientBox.primaryText, controlUnderTest.recipientAddress)
            compare(recipientBox.asset.name, "address")
            verify(!recipientBox.asset.isLetterIdenticon)
            verify(!recipientBox.asset.isImage)
        }

        function test_recpientContextMenu() {
            verify(!!controlUnderTest)

            controlUnderTest.open()

            // recipient box
            const recipientBox = findChild(controlUnderTest.contentItem, "recipientBox")
            verify(!!recipientBox)

            const recipientInfoButtonWithMenu = findChild(recipientBox, "recipientInfoButtonWithMenu")
            verify(!!recipientInfoButtonWithMenu)

            const contextMenu = findChild(recipientInfoButtonWithMenu, "moreMenu")
            verify(!!contextMenu)
            verify(!contextMenu.opened)

            recipientInfoButtonWithMenu.clicked(0)
            verify(contextMenu.opened)

            compare(contextMenu.contentModel.count, 2)

            const externalLink = findChild(contextMenu, "externalLink")
            verify(!!externalLink)
            compare(externalLink.text, qsTr("View receiver address on Etherscan"))
            compare(externalLink.icon.name, "external-link")
            externalLink.triggered()
            tryCompare(signalSpyOpenLink, "count", 1)
            compare(signalSpyOpenLink.signalArguments[0][0],
                    "%1/%2/%3".arg(controlUnderTest.networkBlockExplorerUrl).arg(Constants.networkExplorerLinks.addressPath).arg(controlUnderTest.recipientAddress))
            verify(!contextMenu.opened)

            recipientInfoButtonWithMenu.clicked(0)
            verify(contextMenu.opened)

            const copyButton = findChild(contextMenu, "copyButton")
            verify(!!copyButton)
            compare(copyButton.text, qsTr("Copy receiver address"))
            compare(copyButton.icon.name, "copy")
            copyButton.triggered()
            verify(contextMenu.opened)
        }

        function test_accountInfo() {
            verify(!!controlUnderTest)

            // account box
            const accountBox = findChild(controlUnderTest.contentItem, "accountBox")
            verify(!!accountBox)

            compare(accountBox.caption, qsTr("From"))
            compare(accountBox.primaryText, controlUnderTest.accountName)
            compare(accountBox.secondaryText, SQUtils.Utils.elideAndFormatWalletAddress(controlUnderTest.accountAddress))
            compare(accountBox.asset.emoji, controlUnderTest.accountEmoji)
            compare(accountBox.asset.color, controlUnderTest.accountColor)
        }

        function test_networkInfo() {
            verify(!!controlUnderTest)

            // network box
            const networkBox = findChild(controlUnderTest.contentItem, "networkBox")
            verify(!!networkBox)

            compare(networkBox.caption, qsTr("Network"))
            compare(networkBox.primaryText, controlUnderTest.networkName)
            compare(networkBox.icon, controlUnderTest.networkIconPath)
        }

        function test_feesInfo() {
            verify(!!controlUnderTest)

            // fees box
            const feesBox = findChild(controlUnderTest.contentItem, "feesBox")
            verify(!!feesBox)

            compare(feesBox.caption, qsTr("Fees"))
            compare(feesBox.primaryText, qsTr("Max. fees on %1").arg(controlUnderTest.networkName))

            const fiatFeesText = findChild(feesBox, "fiatFeesText")
            verify(!!fiatFeesText)
            compare(fiatFeesText.text, controlUnderTest.fiatFees)

            const cryptoFeesText = findChild(feesBox, "cryptoFeesText")
            verify(!!cryptoFeesText)
            compare(cryptoFeesText.text, controlUnderTest.cryptoFees)
        }

        function test_loginType_data() {
            return [
                        { tag: "password", loginType: Constants.LoginType.Password, iconName: "password" },
                        { tag: "touchId", loginType: Constants.LoginType.Biometrics, iconName: "touch-id" },
                        { tag: "keycard", loginType: Constants.LoginType.Keycard, iconName: "keycard" }
                    ]
        }

        function test_loginType(data) {
            const loginType = data.loginType
            const iconName = data.iconName

            verify(!!controlUnderTest)

            controlUnderTest.loginType = loginType

            const signButton = findChild(controlUnderTest.footer, "signButton")
            verify(!!signButton)
            compare(signButton.icon.name, iconName)
        }

        function test_loading() {
            verify(!!controlUnderTest)

            compare(controlUnderTest.feesLoading, false)

            const signButton = findChild(controlUnderTest.footer, "signButton")
            verify(!!signButton)
            compare(signButton.interactive, true)

            const footerFiatFeesText = findChild(controlUnderTest.footer, "footerFiatFeesText")
            verify(!!footerFiatFeesText)
            compare(footerFiatFeesText.loading, false)

            const footerEstTimeText = findChild(controlUnderTest.footer, "footerEstTimeText")
            verify(!!footerEstTimeText)
            compare(footerEstTimeText.loading, false)

            const fiatFeesText = findChild(controlUnderTest.contentItem, "fiatFeesText")
            verify(!!fiatFeesText)
            compare(fiatFeesText.loading, false)

            const cryptoFeesText = findChild(controlUnderTest.contentItem, "cryptoFeesText")
            verify(!!cryptoFeesText)
            compare(cryptoFeesText.loading, false)

            controlUnderTest.feesLoading = true

            compare(signButton.interactive, false)
            compare(footerFiatFeesText.loading, true)
            compare(footerEstTimeText.loading, true)
            compare(fiatFeesText.loading, true)
            compare(cryptoFeesText.loading, true)
        }

        function test_footerInfo() {
            verify(!!controlUnderTest)

            const fiatFeesText = findChild(controlUnderTest.footer, "footerFiatFeesText")
            verify(!!fiatFeesText)
            compare(fiatFeesText.text, controlUnderTest.fiatFees)

            const footerEstTimeText = findChild(controlUnderTest.footer, "footerEstTimeText")
            verify(!!footerEstTimeText)
            compare(footerEstTimeText.text, controlUnderTest.estimatedTime)
        }

        function test_signButton() {
            verify(!!controlUnderTest)

            const signButton = findChild(controlUnderTest.footer, "signButton")
            verify(!!signButton)
            compare(signButton.interactive, true)

            signButton.clicked()
            compare(signalSpyAccepted.count, 1)
            compare(controlUnderTest.opened, false)
            compare(controlUnderTest.result, Dialog.Accepted)
        }

        function test_rejectButton() {
            verify(!!controlUnderTest)

            const rejectButton = findChild(controlUnderTest.footer, "rejectButton")
            verify(!!rejectButton)
            compare(rejectButton.interactive, true)

            rejectButton.clicked()
            compare(signalSpyRejected.count, 1)
            compare(controlUnderTest.opened, false)
            compare(controlUnderTest.result, Dialog.Rejected)
        }
    }
}
