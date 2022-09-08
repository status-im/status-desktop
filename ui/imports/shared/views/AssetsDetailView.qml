import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.14
import QtQuick.Window 2.12

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.controls 1.0

import "../stores"

Item {
    id: root

    property var token

    signal goBack()

    StatusFlatButton {
        id: backButton
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: -Style.current.xlPadding
        anchors.leftMargin: -Style.current.xlPadding
        icon.name: "arrow-left"
        icon.width: 20
        icon.height: 20
        text: qsTr("Assets")
        size: StatusBaseButton.Size.Large
        onClicked: root.goBack()
    }

    AssetsDetailsHeader {
        id: tokenDetailsHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        width: parent.width
        asset.name: token && token.symbol ? Style.png("tokens/%1".arg(token.symbol)) : ""
        asset.isImage: true
        primaryText: token ? token.name : ""
        secondaryText: token ? LocaleUtils.formatCryptoCurrency(token.totalBalance, token.symbol) : ""
        tertiaryText: token ? LocaleUtils.formatCurrency(token.totalCurrencyBalance, RootStore.currencyStore.currentCurrency.toUpperCase()) : ""
        balances: token && token.balances ? token.balances :  null
        getNetworkColor: function(chainId){
            return RootStore.getNetworkColor(chainId)
        }
        getNetworkIcon: function(chainId){
            return RootStore.getNetworkIcon(chainId)
        }
    }

    ColumnLayout {
        anchors.top: tokenDetailsHeader.bottom
        anchors.topMargin: 24
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        width: parent.width

        spacing: Style.current.padding

        RowLayout {
            Layout.fillWidth: true
            InformationTile {
                maxWidth: parent.width
                primaryText: qsTr("Market Cap")
                secondaryText: token && token.marketCap ? token.marketCap : "---" // FIXME i18n "marketCap" is a string already containing the currency symbol :/
            }
            InformationTile {
                maxWidth: parent.width
                primaryText: qsTr("Day Low")
                secondaryText: token && token.lowDay ? token.lowDay : "---" // FIXME i18n "lowDay" is a string already containing the currency symbol :/
            }
            InformationTile {
                maxWidth: parent.width
                primaryText: qsTr("Day High")
                secondaryText: token && token.highDay ? token.highDay : "---" // FIXME i18n "highDay" is a string already containing the currency symbol :/
            }
            Item {
                Layout.fillWidth: true
            }
            InformationTile {
                readonly property string changePctHour: token ? token.changePctHour : ""
                maxWidth: parent.width
                primaryText: qsTr("Hour")
                secondaryText: changePctHour ? "%1%".arg(LocaleUtils.formatNumber(changePctHour)) : "---"
                secondaryLabel.color: Math.sign(Number(changePctHour)) === 0 ? Theme.palette.directColor1 :
                                                                               Math.sign(Number(changePctHour)) === -1 ? Theme.palette.dangerColor1 :
                                                                                                                         Theme.palette.successColor1
            }
            InformationTile {
                readonly property string changePctDay: token ? token.changePctDay : ""
                maxWidth: parent.width
                primaryText: qsTr("Day")
                secondaryText: changePctDay ? "%1%".arg(LocaleUtils.formatNumber(changePctDay)) : "---"
                secondaryLabel.color: Math.sign(Number(changePctDay)) === 0 ? Theme.palette.directColor1 :
                                                                              Math.sign(Number(changePctDay)) === -1 ? Theme.palette.dangerColor1 :
                                                                                                                       Theme.palette.successColor1
            }
            InformationTile {
                readonly property string changePct24hour: token ? token.changePct24hour : ""
                maxWidth: parent.width
                primaryText: qsTr("24 Hours")
                secondaryText: changePct24hour ? "%1%".arg(LocaleUtils.formatNumber(changePct24hour)) : "---"
                secondaryLabel.color: Math.sign(Number(changePct24hour)) === 0 ? Theme.palette.directColor1 :
                                                                                 Math.sign(Number(changePct24hour)) === -1 ? Theme.palette.dangerColor1 :
                                                                                                                             Theme.palette.successColor1
            }
        }

        StatusTabBar {
            Layout.fillWidth: true
            Layout.topMargin: Style.current.xlPadding

            StatusTabButton {
                leftPadding: 0
                width: implicitWidth
                text: qsTr("Overview")
            }
        }

        StackLayout {
            id: stack
            Layout.fillWidth: true
            Layout.fillHeight: true
            StatusScrollView {
                id: scrollView
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: parent.height
                ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                topPadding: 8
                bottomPadding: 8
                Flow {
                    id: detailsFlow

                    readonly property bool isOverflowing:  detailsFlow.width - tagsLayout.width - tokenDescriptionText.width < 24

                    spacing: 24

                    width: scrollView.availableWidth
                    StatusBaseText {
                        id: tokenDescriptionText
                        width: Math.max(536 , scrollView.availableWidth - tagsLayout.width - 24)

                        font.pixelSize: 15
                        lineHeight: 22
                        lineHeightMode: Text.FixedHeight
                        text: token ? token.description : ""
                        color: Theme.palette.directColor1
                        elide: Text.ElideRight
                        wrapMode: Text.Wrap
                        textFormat: Qt.RichText
                    }
                    ColumnLayout {
                        id: tagsLayout
                        spacing: 10
                        InformationTag {
                            id: website
                            Layout.alignment: detailsFlow.isOverflowing ? Qt.AlignLeft : Qt.AlignRight
                            iconAsset.icon: "browser"
                            tagPrimaryLabel.text: qsTr("Website")
                            controlBackground.color: Theme.palette.baseColor2
                            controlBackground.border.color: "transparent"
                            visible: token && token.assetWebsiteUrl !== ""
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Global.openLink(token.assetWebsiteUrl)
                            }
                        }
                        InformationTag {
                            id: smartContractAddress
                            Layout.alignment: detailsFlow.isOverflowing ? Qt.AlignLeft : Qt.AlignRight

                            image.source: token  && token.builtOn !== "" ? Style.svg("tiny/" + RootStore.getNetworkIconUrl(token.builtOn)) : ""
                            tagPrimaryLabel.text: token && token.builtOn !== "" ? RootStore.getNetworkName(token.builtOn) : "---"
                            tagSecondaryLabel.text: token && token.smartContractAddress !== "" ? token.smartContractAddress : "---"
                            controlBackground.color: Theme.palette.baseColor2
                            controlBackground.border.color: "transparent"
                            visible: token && token.builtOn !== "" && token.smartContractAddress !== ""
                        }
                    }
                }
            }
        }
    }
}
