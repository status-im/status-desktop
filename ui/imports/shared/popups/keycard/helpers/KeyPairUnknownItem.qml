import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import AppLayouts.Wallet.stores 1.0 as WalletStore

import utils 1.0

Rectangle {
    id: root

    property string keyPairKeyUid: ""
    property string keyPairName: ""
    property string keyPairIcon: ""
    property string keyPairImage: ""
    property string keyPairDerivedFrom: ""
    property bool keyPairCardLocked: false
    property var keyPairAccounts

    color: Theme.palette.baseColor2
    radius: Theme.halfPadding
    implicitWidth: 448
    implicitHeight: 198

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.halfPadding

        StatusListItem {
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width
            color: "transparent"
            title: root.keyPairName

            asset {
                width: root.keyPairIcon? 24 : 40
                height: root.keyPairIcon? 24 : 40
                name: root.keyPairImage? root.keyPairImage : root.keyPairIcon
                isImage: !!root.keyPairImage
                color: root.keyPairKeyUid === userProfile.keyUid?
                           Utils.colorForPubkey(userProfile.pubKey) :
                           root.keyPairCardLocked? Theme.palette.dangerColor1 : Theme.palette.primaryColor1
                letterSize: Math.max(4, asset.width / 2.4)
                charactersLen: 2
                isLetterIdenticon: !root.keyPairIcon && !asset.name.toString()
                bgColor: root.keyPairCardLocked? Theme.palette.dangerColor3 : Theme.palette.primaryColor3
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.palette.separator
        }

        StatusBaseText {
            Layout.preferredWidth: parent.width - 2 * Theme.padding
            Layout.leftMargin: Theme.padding
            Layout.alignment: Qt.AlignLeft
            text: qsTr("Active Accounts")
            font.pixelSize: Constants.keycard.general.fontSize2
            color: Theme.palette.baseColor1
            wrapMode: Text.WordWrap
        }

        StatusListView {
            id: accounts
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width
            Layout.bottomMargin: Theme.padding
            clip: true
            spacing: Theme.halfPadding * 0.5
            model: root.keyPairAccounts

            delegate: Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2 * Theme.padding
                height: Theme.xlPadding * 2
                color: Theme.palette.statusModal.backgroundColor
                radius: Theme.halfPadding

                RowLayout {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Theme.padding
                    anchors.rightMargin: Theme.padding

                    ColumnLayout {

                        Component {
                            id: balance
                            StatusBaseText {
                                text: LocaleUtils.currencyAmountToLocaleString(model.account.balance)
                                wrapMode: Text.WordWrap
                                font.pixelSize: Constants.keycard.general.fontSize2
                                color: Theme.palette.baseColor1
                            }
                        }

                        Component {
                            id: fetchingBalance
                            StatusLoadingIndicator {
                                width: 12
                                height: 12
                            }
                        }

                        Component {
                            id: path
                            StatusBaseText {
                                text: model.account.path
                                wrapMode: Text.WordWrap
                                font.pixelSize: Constants.keycard.general.fontSize2
                                color: Theme.palette.baseColor1
                            }
                        }

                        Row {
                            spacing: 0
                            padding: 0
                            StatusBaseText {
                                id: address
                                text: StatusQUtils.Utils.elideText(model.account.address, 6, 4)
                                wrapMode: Text.WordWrap
                                font.pixelSize: Constants.keycard.general.fontSize2
                                color: Theme.palette.directColor1
                            }

                            StatusFlatRoundButton {
                                height: 20
                                width: 20
                                icon.name: "external"
                                icon.width: 16
                                icon.height: 16
                                onClicked: {
                                    let link = Utils.getUrlForAddressOnNetwork(Constants.networkShortChainNames.mainnet,
                                                                               WalletStore.RootStore.areTestNetworksEnabled,
                                                                               model.account.address)
                                    Global.openLink(link)
                                }
                            }
                        }

                        Loader {
                            active: Global.appIsReady
                            sourceComponent: path
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height
                    }

                    Loader {
                        Layout.alignment: Qt.AlignVCenter
                        sourceComponent: Global.appIsReady?
                                             (model.account.balanceFetched? balance : fetchingBalance)
                                           : path
                    }
                }
            }
        }
    }
}
