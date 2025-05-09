import QtQuick 2.15
import QtQuick.Controls 2.15

import QtTest 1.15

import StatusQ 0.1

import SortFilterProxyModel 0.2
import AppLayouts.Communities.panels 1.0

import Models 1.0

import StatusQ.Core.Utils 0.1 as StatusQUtils

Item {

    id: root
    width: 600
    height: 800

    Component {
        id: componentUnderTest

        MintTokensSettingsPanel {
            communityId: "88"
            communityName: "SuperRare"
            communityLogo: ModelsData.icons.superRare
            communityColor: "Light pink"
            isOwner: true
            isTokenMasterOwner: true
            isAdmin: true
            referenceAssetsBySymbolModel: ListModel {
                ListElement {
                    name: "eth"
                    symbol: "ETH"
                }
                ListElement {
                    name: "dai"
                    symbol: "DAI"
                }
                ListElement {
                    name: "snt"
                    symbol: "SNT"
                }
            }

            anchors.fill: parent
        }
    }

    property MintTokensSettingsPanel mintTokensSettingsPanel

    TestCase {
        name: "MintTokensSettingsPanel"
        when: windowShown

        function init() {
            skip("This test should be enabled back after migrating to QT6")
            mintTokensSettingsPanel = createTemporaryObject(componentUnderTest,
                                                            root)
        }

        function htmlToPlainText(html) {
            return html.replace(/<[^>]+>/g, "")
        }

        function test_mintTokensIntroPages() {

            const introPanel = findChild(mintTokensSettingsPanel, "introPanel")
            const infoBoxPanel = findChild(mintTokensSettingsPanel,
                                           "infoBoxPanel")
            const infoBoxPanelButton = findChild(mintTokensSettingsPanel,
                                                 "statusInfoBoxPanelButton")

            waitForRendering(mintTokensSettingsPanel)
            compare(introPanel.title, "Community tokens")
            compare(introPanel.subtitle,
                    "You can mint custom tokens and import tokens for your community")
            compare(JSON.stringify(introPanel.checkersModel), JSON.stringify(
                        ["Create remotely destructible soulbound tokens for admin permissions", "Reward individual members with custom tokens for their contribution", "Mint tokens for use with community and channel permissions"]))

            compare(infoBoxPanel.title, "Get started")
            compare(infoBoxPanel.text.trim().split(/\s+/).slice(0, 4).join(" "),
                    "In order to Mint,")
            compare(infoBoxPanel.buttonText, "Mint Owner token")
            compare(infoBoxPanel.buttonVisible, true)

            mouseClick(infoBoxPanelButton)

            waitForRendering(mintTokensSettingsPanel)
            waitForItemPolished(mintTokensSettingsPanel)

            tryCompare(mintTokensSettingsPanel.currentItem, "objectName",
                       "ownerTokenPage")

            const settingsPage = findChild(mintTokensSettingsPanel.currentItem,
                                         "welcomeView")


            compare(htmlToPlainText(((findChild(settingsPage,
                                                "introPanelText")).text).replace(/’/g, "'")),
                    "Your Owner token will give you permissions to access the token management features for your community. This token is very important - only one will ever exist, and if this token gets lost then access to the permissions it enables for your community will be lost forever as well.
                        Minting your Owner token also automatically mints your community's TokenMaster token.  You can airdrop your community's TokenMaster token to anybody you wish to grant both Admin permissions and permission to access your community's token management functions to.
                        Only the hodler of the Owner token can airdrop TokenMaster tokens. TokenMaster tokens are soulbound (meaning they can't be transferred), and you (the hodler of the Owner token) can remotely destruct a TokenMaster token at any time, to revoke TokenMaster permissions from any individual.")
            compare(JSON.stringify((findChild(
                                        settingsPage,
                                        "ownerChecklist")).checkersModel),
                    JSON.stringify(
                        ["Only 1 will ever exist", "Hodler is the owner of the Community", "Ability to airdrop / destroy TokenMaster token", "Ability to mint and airdrop Community tokens"]))
            compare(JSON.stringify((findChild(
                                        settingsPage,
                                        "masterChecklist")).checkersModel),
                    JSON.stringify(
                        ["Unlimited supply", "Grants full Community admin rights", "Ability to mint and airdrop Community tokens", "Non-transferrable", "Remotely destructible by the Owner token hodler"]))
        }
    }
}
