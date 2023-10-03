import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Storybook 1.0
import Models 1.0

import AppLayouts.Communities.popups 1.0
import AppLayouts.Communities.helpers 1.0

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            PopupBackground {
                anchors.fill: parent
            }

            Button {
                anchors.centerIn: parent
                text: "Reopen"

                onClicked: dialog.open()
            }

            FinaliseOwnershipPopup {
                id: dialog

                anchors.centerIn: parent
                closePolicy: Popup.NoAutoClose
                visible: true
                modal: false

                communityName: communityNameText.text
                communityLogo: ModelsData.collectibles.doodles
                communityColor: color1.checked ?  "#FFC4E9" : "#f44336"

                tokenSymbol: communitySymbolText.text
                tokenChainName: tokenChainText.text

                accounts: ListModel {
                    ListElement {
                        name: "Test account"
                        emoji: "😋"
                        address: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
                        color: "red"
                    }
                    ListElement {
                        name: "Another account - generated"
                        emoji: "🚗"
                        address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8888"
                        color: "blue"
                    }
                }

                feeText: !feesErrorChecker.checked ? "13.34 USD (0.0072 ETH)" : ""
                isFeeLoading: feesLoadingChecker.checked
                feeErrorText: feesErrorChecker.checked ? "Error getting fees" : ""

                onRejectClicked: logs.logEvent("FinaliseOwnershipPopup::onRejectClicked")
                onFinaliseOwnershipClicked: logs.logEvent("FinaliseOwnershipPopup::onFinaliseOwnershipClicked")
                onVisitCommunityClicked: logs.logEvent("FinaliseOwnershipPopup::onVisitCommunityClicked")
                onOpenControlNodeDocClicked: logs.logEvent("FinaliseOwnershipPopup::onOpenControlNodeDocClicked --> " + link)
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        Column {
            spacing: 12

            Label {
                text: "Community Name"
                font.bold: true
            }

            TextInput {
                id: communityNameText

                text: "Doodles"

            }

            Label {
                text: "Community Symbol"
                font.bold: true
            }

            TextInput {
                id: communitySymbolText

                text: "OWNDOO"
            }

            Label {
                text: "Token chain name"
                font.bold: true
            }

            TextInput {
                id: tokenChainText

                text: "Optimism"
            }

            Label {
                text: "Community Logo"
                font.bold: true
            }

            Column {

                RadioButton {
                    id: doodleLogo

                    text: "Doodle"
                    checked: true

                    onCheckedChanged: dialog.communityLogo =  ModelsData.collectibles.doodles
                }

                RadioButton {
                    id: manaLogo

                    text: "Mana"

                    onCheckedChanged: dialog.communityLogo =  ModelsData.collectibles.mana
                }

                RadioButton {
                    id: superRareLogo

                    text: "Status"

                    onCheckedChanged: dialog.communityLogo =  ModelsData.collectibles.custom
                }
            }

            Label {
                text: "Community Color"
                font.bold: true
            }

            RowLayout {
                RadioButton {
                    id: color1

                    text: "Light pink"
                    checked: true
                }

                RadioButton {
                    text: "Orange"
                }
            }

            Label {
                text: "Fees"
                font.bold: true
            }

            Switch {
                id: feesErrorChecker

                text: "Is there fees error?"
                checked: false
            }

            Switch {
                id: feesLoadingChecker

                text: "Is fees loading?"
                checked: false
            }
        }
    }
}

// category: Popups

// https://www.figma.com/file/qHfFm7C9LwtXpfdbxssCK3/Kuba%E2%8E%9CDesktop---Communities?type=design&node-id=37206%3A87869&mode=design&t=olSRjSKm7CM2vv5O-1
// https://www.figma.com/file/qHfFm7C9LwtXpfdbxssCK3/Kuba%E2%8E%9CDesktop---Communities?type=design&node-id=37206%3A93588&mode=design&t=olSRjSKm7CM2vv5O-1
