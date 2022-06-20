import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1

import "../panels"
import "."

// TODO: replace with StatusModal
ModalPopup {
    id: popup

    height: Style.dp(300 + (showPriceLimitWarning ? 65 : 0) + (showTipLimitWarning ? 65 : 0))
    width: Style.dp(400)
    title: qsTr("Are you sure?")

    property var onConfirm: function(){}

    property double currentBaseFee: 0
    property double currentMinimumTip: 0
    property double currentAverageTip: 0
    property double tipLimit: 0
    property double suggestedTipLimit: 0
    property double priceLimit: 0
    property double suggestedPriceLimit: 0

    property bool showPriceLimitWarning: false
    property bool showTipLimitWarning: false

    Column {
        id: content
        width: Style.dp(450)
        height: parent.height
        spacing: Style.dp(10)

        StyledText {
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding
            text: qsTr("Your priority fee is below our suggested parameters.")
            font.pixelSize: Style.current.additionalTextSize
            wrapMode: Text.WordWrap
            color: Style.current.secondaryText
        }

        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Style.current.smallPadding
            height: Style.dp(20)

            StyledText {
                text: qsTr("Current base fee")
                font.pixelSize: Style.current.additionalTextSize
                width: Style.dp(190)
                anchors.left: parent.left
            }

            StyledText {
                text: qsTr("%1 Gwei").arg(currentBaseFee)
                font.pixelSize: Style.current.additionalTextSize
                width: Style.dp(190)
                anchors.right: parent.right
            }
        }

        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Style.current.smallPadding
            height: Style.dp(20)

            StyledText {
                text: qsTr("Current minimum tip")
                font.pixelSize: Style.current.additionalTextSize
                width: Style.dp(190)
                anchors.left: parent.left
            }

            StyledText {
                text: qsTr("%1 Gwei").arg(currentMinimumTip)
                font.pixelSize: Style.current.additionalTextSize
                width: Style.dp(190)
                anchors.right: parent.right
            }
        }

        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Style.current.smallPadding
            height: Style.dp(20)

            StyledText {
                text: qsTr("Current average tip")
                font.pixelSize: Style.current.additionalTextSize
                width: Style.dp(190)
                anchors.left: parent.left
            }

            StyledText {
                text: qsTr("%1 Gwei").arg(currentAverageTip)
                font.pixelSize: Style.current.additionalTextSize
                width: Style.dp(190)
                anchors.right: parent.right
            }
        }

        Rectangle {
            id: tipLimitRect
            width: Style.dp(368)
            visible: showTipLimitWarning
            height: visible ? Style.dp(70) : 0
            radius: Style.current.radius
            color: Style.current.backgroundHoverLight

            Column {
                anchors.top: parent.top
                anchors.topMargin: Style.current.smallPadding
                anchors.left: parent.left
                anchors.leftMargin: Style.current.smallPadding
                height: Style.dp(100)
                width: Style.dp(450) - Style.current.smallPadding
                spacing: Style.dp(10)

                Item {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Style.dp(20)
                    StyledText {
                        text: qsTr("Your tip limit")
                        font.pixelSize: Style.current.additionalTextSize
                        width: Style.dp(190)
                        anchors.left: parent.left
                        color: Style.current.red
                    }

                    StyledText {
                        text: qsTr("%1 Gwei").arg(tipLimit)
                        font.pixelSize: Style.current.additionalTextSize
                        width: Style.dp(190)
                        anchors.right: parent.right
                        color: Style.current.red
                    }
                }

                Item {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Style.dp(20)

                    StyledText {
                        text: qsTr("Suggested minimum tip")
                        font.pixelSize: Style.current.additionalTextSize
                        width: Style.dp(190)
                        anchors.left: parent.left
                    }

                    StyledText {
                        text: qsTr("%1 Gwei").arg(suggestedTipLimit)
                        font.pixelSize: Style.current.additionalTextSize
                        width: Style.dp(190)
                        anchors.right: parent.right
                    }
                }
            }

        }

        Rectangle {
            id: minPriceLimitRect
            width: Style.dp(368)
            visible: showPriceLimitWarning
            height: visible ? Style.dp(70) : 0
            radius: Style.current.radius
            color: Style.current.backgroundHoverLight

            Column {
                anchors.top: parent.top
                anchors.topMargin: Style.current.smallPadding
                anchors.left: parent.left
                anchors.leftMargin: Style.current.smallPadding
                height: Style.dp(100)
                width: Style.dp(450) - Style.current.smallPadding
                spacing: Style.dp(10)

                Item {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Style.dp(20)
                    StyledText {
                        text: qsTr("Your price limit")
                        font.pixelSize: Style.current.additionalTextSize
                        width: Style.dp(190)
                        anchors.left: parent.left
                        color: Style.current.red
                    }

                    StyledText {
                        text: qsTr("%1 Gwei").arg(priceLimit)
                        font.pixelSize: Style.current.additionalTextSize
                        width: Style.dp(190)
                        anchors.right: parent.right
                        color: Style.current.red
                    }
                }

                Item {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Style.dp(20)

                    StyledText {
                        text: qsTr("Suggested minimum price limit")
                        font.pixelSize: Style.current.additionalTextSize
                        width: Style.dp(190)
                        anchors.left: parent.left
                    }

                    StyledText {
                        text: qsTr("%1 Gwei").arg(suggestedPriceLimit)
                        font.pixelSize: Style.current.additionalTextSize
                        width: Style.dp(190)
                        anchors.right: parent.right
                    }
                }
            }
        }

    }

    footer: Item {
        id: footerContainer
        width: parent.width

        StatusButton {
            id: cancelButton
            anchors.right: confirmButton.left
            anchors.rightMargin: Style.current.smallPadding
            text: qsTr("Change Limit")
            anchors.bottom: parent.bottom
            onClicked: popup.destroy()
        }

        StatusButton {
            id: confirmButton
            type: StatusBaseButton.Type.Danger
            anchors.right: parent.right
            anchors.rightMargin: Style.current.smallPadding
            text: qsTr("Continue anyway")
            anchors.bottom: parent.bottom
            onClicked: {
                popup.onConfirm();
                popup.destroy();
            }
        }
    }
}



