import QtQuick 2.15
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Communities.panels 1.0

import utils 1.0

StatusScrollView {
    id: root

    property int viewWidth: 560 // by design

    required property string communityLogo
    required property color communityColor
    required property string communityName

    signal nextClicked

    padding: 0
    contentWidth: mainLayout.width
    contentHeight: mainLayout.height

    QtObject {
        id: d

        function generateSymbol(isOwner) {
            // TODO: Add a kind of verification for not repeating symbols
            const shortName = root.communityName.substring(0, 3)
            if(isOwner)
                return "OWN" + shortName.toUpperCase()
            else
                return "TM" + shortName.toUpperCase()
        }
    }

    ColumnLayout {
        id: mainLayout

        width: root.viewWidth
        spacing: 20

        StatusBaseText {
            id: introPanel

            Layout.fillWidth: true

            wrapMode: Text.WordWrap
            lineHeight: 1.2
            font.pixelSize: Style.current.primaryTextFontSize
            text: qsTr("Your <b>Owner token</b> will give you permissions to access the token management features for your community. This token is very important - only one will ever exist, and if this token gets lost then access to the permissions it enables for your community will be lost forever as well.<br><br>
                        Minting your Owner token also automatically mints your community’s <b>TokenMaster token</b>.  You can airdrop your community’s TokenMaster token to anybody you wish to grant both Admin permissions and permission to access your community’s token management functions to.<br><br>
                        Only the hodler of the Owner token can airdrop TokenMaster tokens. TokenMaster tokens are soulbound (meaning they can’t be transferred), and you (the hodler of the Owner token) can remotely destruct a TokenMaster token at any time, to revoke TokenMaster permissions from any individual.")
        }

        InfoPanel {
            isOwner: true
            checkersModel: [
                qsTr("Only 1 will ever exist"),
                qsTr("Hodler is the owner of the Community"),
                qsTr("Ability to airdrop / destroy TokenMaster token"),
                qsTr("Ability to mint and airdrop Community tokens")
            ]
        }

        InfoPanel {
            isOwner: false
            showTag: true
            checkersModel: [
                qsTr("Unlimited supply"),
                qsTr("Grants full Community admin rights"),
                qsTr("Ability to mint and airdrop Community tokens"),
                qsTr("Non-transferrable"),
                qsTr("Remotely destructible by the Owner token hodler")
            ]
        }

        component InfoPanel : Rectangle {
            id: panel

            property bool isOwner
            property bool showTag
            property alias checkersModel: checkersItems.model
            readonly property int margins: Style.current.bigPadding

            Layout.fillWidth:  true
            Layout.preferredHeight: panelRow.implicitHeight

            color: "transparent"
            radius: 8
            border.color: Theme.palette.baseColor2

            RowLayout {
                id: panelRow

                width: parent.width
                spacing: panel.margins

                PrivilegedTokenArtworkPanel {
                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin: panel.margins
                    Layout.leftMargin: Layout.topMargin

                    isOwner: panel.isOwner
                    artwork: root.communityLogo
                    color: root.communityColor
                    showTag: panel.showTag
                }

                ColumnLayout {
                    id: col

                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin: panel.margins
                    Layout.bottomMargin: panel.margins
                    Layout.fillWidth: true

                    Item {
                        id: panelTextHeader

                        Layout.fillWidth: true
                        Layout.preferredHeight: headerRow.implicitHeight
                        Layout.rightMargin: panel.margins

                        RowLayout {
                            id: headerRow

                            spacing: Style.current.halfPadding

                            StatusBaseText {
                                Layout.alignment: Qt.AlignBottom
                                Layout.maximumWidth: panelTextHeader.width - symbol.width

                                text: panel.isOwner ? qsTr("%1 Owner token").arg(root.communityName) :
                                                      qsTr("%1 TokenMaster token").arg(root.communityName)
                                font.bold: true
                                font.pixelSize: 17
                                elide: Text.ElideMiddle
                            }

                            StatusBaseText {
                                id: symbol

                                Layout.alignment: Qt.AlignBottom

                                text: d.generateSymbol(panel.isOwner)
                                font.pixelSize: Style.current.primaryTextFontSize
                                color: Theme.palette.baseColor1
                            }
                        }
                    }

                    ColumnLayout {
                        id: checkersColumn

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        Layout.topMargin: 6

                        Repeater {
                            id: checkersItems

                            RowLayout {
                                StatusIcon {
                                    icon: "tiny/checkmark"
                                    color: Theme.palette.successColor1
                                    width: 20
                                    height: width
                                }

                                StatusBaseText {
                                    Layout.fillWidth: true
                                    Layout.rightMargin: panel.margins

                                    text: modelData
                                    lineHeight: 1.2
                                    font.pixelSize: Style.current.additionalTextSize
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
                    }
                }
            }
        }

        StatusButton {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: Style.current.bigPadding

            text: qsTr("Next")

            onClicked: root.nextClicked()
        }
    }
}
