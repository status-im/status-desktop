import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.stores 1.0 as SharedStore

Rectangle {
    id: root

    property string keyPairPubKey: ""
    property string keyPairName: ""
    property string keyPairIcon: ""
    property string keyPairImage: ""
    property string keyPairDerivedFrom: ""
    property var keyPairAccounts

    color: Theme.palette.baseColor2
    radius: Style.current.halfPadding
    implicitWidth: 448
    implicitHeight: 198

    ColumnLayout {
        anchors.fill: parent
        spacing: Style.current.halfPadding

        StatusListItem {
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width
            color: "transparent"
            title: root.keyPairName

            asset {
                width: 24
                height: 24
                name: root.keyPairIcon
                color: Utils.colorForPubkey(root.keyPairPubKey)
                letterSize: Math.max(4, asset.width / 2.4)
                charactersLen: 2
                isLetterIdenticon: false
                bgColor: Theme.palette.primaryColor3
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Style.current.grey3
        }

        StatusBaseText {
            Layout.preferredWidth: parent.width - 2 * Style.current.padding
            Layout.leftMargin: Style.current.padding
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
            Layout.bottomMargin: Style.current.padding
            clip: true
            spacing: Style.current.halfPadding * 0.5
            model: root.keyPairAccounts

            delegate: Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2 * Style.current.padding
                height: Style.current.xlPadding * 2
                color: Theme.palette.statusModal.backgroundColor
                radius: Style.current.halfPadding

                RowLayout {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Style.current.padding
                    anchors.rightMargin: Style.current.padding

                    ColumnLayout {
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
                                    Qt.openUrlExternally("https://etherscan.io/address/%1".arg(model.account.address))
                                }
                            }
                        }

                        StatusBaseText {
                            text: model.account.path
                            wrapMode: Text.WordWrap
                            font.pixelSize: Constants.keycard.general.fontSize2
                            color: Theme.palette.baseColor1
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height
                    }

                    StatusBaseText {
                        Layout.alignment: Qt.AlignVCenter
                        text: {
                            if (Global.appMain) {
                                return "%1%2".arg(SharedStore.RootStore.currencyStore.currentCurrencySymbol)
                                .arg(Utils.toLocaleString(model.account.balance.toFixed(2), appSettings.locale, {"model.account.currency": true}))
                            }
                            // without language/model refactor no way to read currency symbol or `appSettings.locale` before user logs in
                            return "$%1".arg(Utils.toLocaleString(model.account.balance.toFixed(2), localAppSettings.language, {"model.account.currency": true}))
                        }
                        wrapMode: Text.WordWrap
                        font.pixelSize: Constants.keycard.general.fontSize2
                        color: Theme.palette.baseColor1
                    }
                }
            }
        }
    }
}
