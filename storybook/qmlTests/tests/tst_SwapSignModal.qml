import QtQuick 2.15
import QtQuick.Controls 2.15
import QtTest 1.15
import QtQml 2.15

import Models 1.0

import StatusQ.Core.Utils 0.1 as SQUtils

import AppLayouts.Wallet.popups.swap 1.0
import shared.stores 1.0

import utils 1.0

Item {
    id: root
    width: 600
    height: 400

    QtObject {
        id: d
        readonly property var currencyStore: CurrenciesStore{}
    }

    Component {
        id: componentUnderTest
        SwapSignModal {
            anchors.centerIn: parent

            currencyStore: d.currencyStore

            fromTokenSymbol: "DAI"
            fromTokenAmount: "100.07"
            fromTokenContractAddress: "0x6B175474E89094C44Da98b954EedeAC495271d0F"

            toTokenSymbol: "USDT"
            toTokenAmount: "142.07"
            toTokenContractAddress: "0xdAC17F958D2ee523a2206206994597C13D831ec7"

            accountName: "Hot wallet (generated)"
            accountAddress: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881"
            accountEmoji: "🚗"
            accountColor: Utils.getColorForId(Constants.walletAccountColors.primary)

            networkShortName: Constants.networkShortChainNames.mainnet
            networkName: "Mainnet"
            networkIconPath: Style.svg("network/Network=Ethereum")
            networkBlockExplorerUrl: "https://etherscan.io/"

            serviceProviderName: Constants.swap.paraswapName
            serviceProviderURL: Constants.swap.termsAndConditionParaswapUrl

            fiatFees: "1.54 EUR"
            cryptoFees: "0.001 ETH"
            slippage: 0.2

            loginType: Constants.LoginType.Password
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

    property SwapSignModal controlUnderTest: null

    TestCase {
        name: "SwapSignModal"
        when: windowShown

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
            signalSpyAccepted.clear()
            signalSpyRejected.clear()
        }

        function test_basicGeometry() {
            verify(!!controlUnderTest)
            verify(controlUnderTest.width > 0)
            verify(controlUnderTest.height > 0)
        }

        function test_fromToProps_data() {
            return [
                        {tag: "ETH", toTokenSymbol: "ETH"},
                        {tag: "DAI", toTokenSymbol: "DAI"},
                    ]
        }

        function test_fromToProps(data) {
            verify(!!controlUnderTest)
            controlUnderTest.fromTokenSymbol = "SNT"
            controlUnderTest.fromTokenAmount = "1000.123456789"
            controlUnderTest.fromTokenContractAddress = "Oxdeadbeef"
            controlUnderTest.toTokenSymbol = data.toTokenSymbol
            controlUnderTest.toTokenAmount = "1.42"
            controlUnderTest.toTokenContractAddress = "0xdeadcaff"

            // title & subtitle
            compare(controlUnderTest.title, qsTr("Sign Swap"))
            compare(controlUnderTest.subtitle, qsTr("%1 to %2").arg(d.currencyStore.formatCurrencyAmount(controlUnderTest.fromTokenAmount, controlUnderTest.fromTokenSymbol))
                    .arg(d.currencyStore.formatCurrencyAmount(controlUnderTest.toTokenAmount, controlUnderTest.toTokenSymbol)))

            // info box
            const headerText = findChild(controlUnderTest.contentItem, "headerText")
            verify(!!headerText)
            compare(headerText.text, qsTr("Swap 1000.123456789 SNT to 1.42 %3 in %1 on %2").arg(controlUnderTest.accountName).arg(controlUnderTest.networkName).arg(data.toTokenSymbol))
            const fromImage = findChild(controlUnderTest.contentItem, "fromImageIdenticon")
            verify(!!fromImage)
            compare(fromImage.asset.name, Constants.tokenIcon(controlUnderTest.fromTokenSymbol))
            const toImage = findChild(controlUnderTest.contentItem, "toImageIdenticon")
            verify(!!toImage)
            compare(toImage.asset.name, Constants.tokenIcon(controlUnderTest.toTokenSymbol))

            // pay box
            const payBox = findChild(controlUnderTest.contentItem, "payBox")
            verify(!!payBox)
            compare(payBox.caption, qsTr("Pay"))
            compare(payBox.primaryText, "%1 %2".arg(controlUnderTest.fromTokenAmount).arg(controlUnderTest.fromTokenSymbol))
            compare(payBox.secondaryText, SQUtils.Utils.elideAndFormatWalletAddress(controlUnderTest.fromTokenContractAddress))

            // receive box
            const receiveBox = findChild(controlUnderTest.contentItem, "receiveBox")
            verify(!!receiveBox)
            compare(receiveBox.caption, qsTr("Receive"))
            compare(receiveBox.primaryText, "%1 %2".arg(controlUnderTest.toTokenAmount).arg(controlUnderTest.toTokenSymbol))
            compare(receiveBox.secondaryText,
                    data.toTokenSymbol === "ETH" ? ""
                                                 : SQUtils.Utils.elideAndFormatWalletAddress(controlUnderTest.toTokenContractAddress))
        }

        function test_accountInfo() {
            verify(!!controlUnderTest)

            // account box
            const accountBox = findChild(controlUnderTest.contentItem, "accountBox")
            verify(!!accountBox)

            compare(accountBox.caption, qsTr("In account"))
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

            const fiatFeesText = findChild(controlUnderTest.contentItem, "fiatFeesText")
            verify(!!fiatFeesText)
            compare(fiatFeesText.loading, false)

            const cryptoFeesText = findChild(controlUnderTest.contentItem, "cryptoFeesText")
            verify(!!cryptoFeesText)
            compare(cryptoFeesText.loading, false)

            controlUnderTest.feesLoading = true

            compare(signButton.interactive, false)
            compare(footerFiatFeesText.loading, true)
            compare(fiatFeesText.loading, true)
            compare(cryptoFeesText.loading, true)
        }

        function test_footerInfo() {
            verify(!!controlUnderTest)

            const fiatFeesText = findChild(controlUnderTest.footer, "footerFiatFeesText")
            verify(!!fiatFeesText)
            compare(fiatFeesText.text, controlUnderTest.fiatFees)

            const maxSlippageText = findChild(controlUnderTest.footer, "footerMaxSlippageText")
            verify(!!maxSlippageText)
            compare(maxSlippageText.text, "%1%".arg(controlUnderTest.slippage))
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
