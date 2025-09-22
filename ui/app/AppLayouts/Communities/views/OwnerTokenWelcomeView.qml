import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Controls
import StatusQ.Core.Theme

import AppLayouts.Communities.controls
import AppLayouts.Communities.panels
import AppLayouts.Communities.helpers

import utils

StatusScrollView {
    id: root

    property int preferredContentWidth: width
    property int internalRightPadding: 0

    required property string communityLogo
    required property color communityColor
    required property string communityName

    signal nextClicked

    padding: 0
    contentWidth: mainLayout.width
    contentHeight: mainLayout.height

    ColumnLayout {
        id: mainLayout

        objectName: "welcomeView"

        width: root.availableWidth
        spacing: 20

        StatusBaseText {
            id: introPanel

            objectName: "introPanelText"

            Layout.fillWidth: true
            Layout.maximumWidth: root.preferredContentWidth
            Layout.rightMargin: root.internalRightPadding

            wrapMode: Text.WordWrap
            lineHeight: 1.2
            font.pixelSize: Theme.primaryTextFontSize
            text: qsTr("Your <b>Owner token</b> will give you permissions to access the token management features for your community. This token is very important - only one will ever exist, and if this token gets lost then access to the permissions it enables for your community will be lost forever as well.<br><br>
                        Minting your Owner token also automatically mints your community’s <b>TokenMaster token</b>.  You can airdrop your community’s TokenMaster token to anybody you wish to grant both Admin permissions and permission to access your community’s token management functions to.<br><br>
                        Only the hodler of the Owner token can airdrop TokenMaster tokens. TokenMaster tokens are soulbound (meaning they can’t be transferred), and you (the hodler of the Owner token) can remotely destruct a TokenMaster token at any time, to revoke TokenMaster permissions from any individual.")
        }

        CommunityInfoPanel {
            
            objectName: "infoPanel_owner"

            Layout.fillWidth: true
            Layout.maximumWidth: root.preferredContentWidth
            Layout.rightMargin: root.internalRightPadding

            communityLogo: root.communityLogo
            communityColor: root.communityColor
            communityName: root.communityName
            isOwner: true
            checkersModel: [
                qsTr("Only 1 will ever exist"),
                qsTr("Hodler is the owner of the Community"),
                qsTr("Ability to airdrop / destroy TokenMaster token"),
                qsTr("Ability to mint and airdrop Community tokens")
            ]
        }

        CommunityInfoPanel {

            objectName: "infoPanel_master"

            Layout.fillWidth: true
            Layout.maximumWidth: root.preferredContentWidth
            Layout.rightMargin: root.internalRightPadding

            communityLogo: root.communityLogo
            communityColor: root.communityColor
            communityName: root.communityName
            showTag: true
            checkersModel: [
                qsTr("Unlimited supply"),
                qsTr("Grants full Community admin rights"),
                qsTr("Ability to mint and airdrop Community tokens"),
                qsTr("Non-transferrable"),
                qsTr("Remotely destructible by the Owner token hodler")
            ]
        }

        StatusButton {
            objectName: "welcomeViewNextButton"

            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: Theme.bigPadding
            Layout.rightMargin: mainLayout.width - Math.min(root.preferredContentWidth,
                                                            mainLayout.width - root.internalRightPadding)
            text: qsTr("Next")

            onClicked: root.nextClicked()
        }
    }
}
