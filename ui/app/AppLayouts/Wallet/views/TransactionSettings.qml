import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import shared.controls 1.0
import shared.popups 1.0

Rectangle {
    id: root

    property string currentBaseFee
    property string currentSuggestedMinPriorityFee
    property string currentSuggestedMaxPriorityFee
    property string currentGasAmount
    property int currentNonce

    property alias normalPrice: optionNormal.subText
    property alias normalTime: optionNormal.additionalText

    property alias fastPrice: optionFast.subText
    property alias fastTime: optionFast.additionalText

    property alias urgentPrice: optionUrgent.subText
    property alias urgentTime: optionUrgent.additionalText

    property alias customPrice: optionCustom.subText
    property alias customTime: optionCustom.additionalText
    property alias customBaseFee: customBaseFee.text
    property alias customPriorityFee: customPriorityFee.text
    property alias customGasAmount: customGasAmount.text
    property alias customNonce: customNonce.text

    property int selectedFeeMode

    signal confirmClicked()
    signal cancelClicked()

    color: Theme.palette.statusModal.backgroundColor
    radius: 8

    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    QtObject {
        id: d

        readonly property bool customMode: root.selectedFeeMode === StatusFeeOption.Type.Custom

        function showAlert(title, text, note, url) {
            infoBox.title = title
            infoBox.text = text
            infoBox.note = note
            infoBox.url = url
            infoBox.active = true
        }
    }

    focus: true

    Keys.onReleased: {
        if (event.key === Qt.Key_Escape) {
            root.cancelClicked()
        }
    }

    Component.onCompleted: root.forceActiveFocus()

    Loader {
        id: infoBox
        anchors.centerIn: root
        active: false

        property string title
        property string text
        property string note
        property string url

        sourceComponent: AlertPopup {
            title: infoBox.title

            width: root.width - 2 * 20

            acceptBtnText: qsTr("Got it")
            cancelBtn.text: !!infoBox.url? qsTr("Read more") : ""
            cancelBtn.icon.name: "external-link"
            cancelBtn.visible: !!infoBox.url

            alertLabel.text: infoBox.text
            alertNote.visible: !!infoBox.note
            alertNote.text: infoBox.note
            alertNote.color: Theme.palette.baseColor1

            onCancelClicked: {
                Qt.openUrlExternally(infoBox.url)
            }

            onClosed: {
                infoBox.active = false
            }
        }

        onLoaded: {
            infoBox.item.open()
        }
    }

    ColumnLayout {
        id: layout

        ColumnLayout {
            Layout.margins: 20

            spacing: 16

            StatusBaseText {
                Layout.preferredWidth: parent.width
                text: qsTr("Transaction settings")
                font.pixelSize: 17
                font.bold: true
                elide: Text.ElideMiddle
            }

            RowLayout {
                id: options
                spacing: 12

                StatusFeeOption {
                    id: optionNormal
                    type: StatusFeeOption.Type.Normal
                    selected: root.selectedFeeMode === StatusFeeOption.Type.Normal
                    showSubText: true
                    showAdditionalText: true

                    onClicked: root.selectedFeeMode = StatusFeeOption.Type.Normal
                }

                StatusFeeOption {
                    id: optionFast
                    type: StatusFeeOption.Type.Fast
                    selected: root.selectedFeeMode === StatusFeeOption.Type.Fast
                    showSubText: true
                    showAdditionalText: true

                    onClicked: root.selectedFeeMode = StatusFeeOption.Type.Fast
                }

                StatusFeeOption {
                    id: optionUrgent
                    type: StatusFeeOption.Type.Urgent
                    selected: root.selectedFeeMode === StatusFeeOption.Type.Urgent
                    showSubText: true
                    showAdditionalText: true

                    onClicked: root.selectedFeeMode = StatusFeeOption.Type.Urgent
                }

                StatusFeeOption {
                    id: optionCustom
                    type: StatusFeeOption.Type.Custom
                    selected: root.selectedFeeMode === StatusFeeOption.Type.Custom
                    showSubText: !!selected
                    showAdditionalText: !!selected
                    unselectedText: "Set your own fees & nonce"

                    onClicked: root.selectedFeeMode = StatusFeeOption.Type.Custom
                }
            }

            StatusBaseText {
                Layout.preferredWidth: parent.width
                visible: !d.customMode
                text: qsTr("Increased base and priority fee, incentivising miners to confirm more quickly")
                color: Theme.palette.baseColor1
                font.pixelSize: Theme.tertiaryTextFontSize
                elide: Text.ElideMiddle
            }

            ShapeRectangle {
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: customLayout.height + customLayout.anchors.margins
                visible: d.customMode

                ColumnLayout {
                    id: customLayout
                    anchors.left: parent.left
                    anchors.margins: 20
                    width: parent.width - 2 * anchors.margins
                    spacing: 16

                    StatusInput {
                        id: customBaseFee
                        Layout.preferredWidth: parent.width
                        Layout.topMargin: 20
                        label: qsTr("Max base fee")
                        labelIcon: "info"
                        labelIconColor: Theme.palette.baseColor1
                        labelIconClickable: true
                        errorMessageCmp.visible: true
                        errorMessageCmp.color: Theme.palette.baseColor1
                        errorMessageCmp.text: qsTr("Current: %1 GWEI").arg(root.currentBaseFee)
                        errorMessageCmp.horizontalAlignment: Text.AlignLeft
                        bottomLabelMessageCmp.text: qsTr("0.0031 ETH")
                        rightPadding: leftPadding
                        input.rightComponent: StatusBaseText {
                            text: "GWEI"
                            color: Theme.palette.baseColor1
                        }

                        onLabelIconClicked: d.showAlert(label,
                                                        qsTr("When your transaction gets included in the block, any difference between your max base fee and the actual base fee will be refunded.\n"),
                                                        qsTr("Note: the ETH amount shown for this value is calculated:\nMax base fee (in GWEI) * Max gas amount"),
                                                        "")
                    }

                    StatusInput {
                        id: customPriorityFee
                        Layout.preferredWidth: parent.width
                        label: qsTr("Priority fee")
                        labelIcon: "info"
                        labelIconColor: Theme.palette.baseColor1
                        labelIconClickable: true
                        errorMessageCmp.visible: true
                        errorMessageCmp.color: Theme.palette.baseColor1
                        errorMessageCmp.text: qsTr("Current: %1 - %2 GWEI").arg(root.currentSuggestedMinPriorityFee).arg(root.currentSuggestedMaxPriorityFee)
                        errorMessageCmp.horizontalAlignment: Text.AlignLeft
                        bottomLabelMessageCmp.text: qsTr("0.0031 ETH")
                        rightPadding: leftPadding
                        input.rightComponent: StatusBaseText {
                            text: "GWEI"
                            color: Theme.palette.baseColor1
                        }

                        onLabelIconClicked: d.showAlert(label,
                                                        qsTr("AKA miner tip. A voluntary fee you can add to incentivise miners or validators to prioritise your transaction.\n\nThe higher the tip, the faster your transaction is likely to be processed, especially curing periods of higher network congestion.\n"),
                                                        qsTr("Note: the ETH amount shown for this value is calculated: Priority fee (in GWEI) * Max gas amount"),
                                                        "")
                    }

                    StatusInput {
                        id: customGasAmount
                        Layout.preferredWidth: parent.width
                        label: qsTr("Max gas amount")
                        labelIcon: "info"
                        labelIconColor: Theme.palette.baseColor1
                        labelIconClickable: true
                        errorMessageCmp.visible: true
                        errorMessageCmp.color: Theme.palette.baseColor1
                        errorMessageCmp.text: qsTr("Current: %1").arg(root.currentGasAmount)
                        errorMessageCmp.horizontalAlignment: Text.AlignLeft
                        rightPadding: leftPadding
                        input.rightComponent: StatusBaseText {
                            text: "UNITS"
                            color: Theme.palette.baseColor1
                        }

                        onLabelIconClicked: d.showAlert(qsTr("Gas amount"),
                                                        qsTr("AKA gas limit. Refers to the maximum number of computational steps (or units of gas) that a transaction can consume. It represents the complexity or amount of work required to execute a transaction or smart contract.\n\nThe gas limit is a cap on how much work the transaction can do on the blockchain. If the gas limit is set too low, the transaction may fail due to insufficient gas."),
                                                        "",
                                                        "")
                    }

                    StatusInput {
                        id: customNonce
                        Layout.preferredWidth: parent.width
                        label: qsTr("Nonce")
                        labelIcon: "info"
                        labelIconColor: Theme.palette.baseColor1
                        labelIconClickable: true
                        errorMessageCmp.visible: true
                        errorMessageCmp.color: Theme.palette.baseColor1
                        errorMessageCmp.text: qsTr("Last transaction: %1").arg(root.currentNonce)
                        errorMessageCmp.horizontalAlignment: Text.AlignLeft
                        rightPadding: leftPadding

                        onLabelIconClicked: d.showAlert(label,
                                                        qsTr("Transaction counter ensuring transactions from your account are processed in the correct order and can’t be replayed. Each new transaction increments the nonce by 1, ensuring uniqueness and preventing double-spending.\n\nIf a transaction with a lower nonce is pending, higher nonce transactions will remain in the queue until the earlier one is confirmed."),
                                                        "",
                                                        "")
                    }
                }
            }

            StatusButton {
                Layout.preferredWidth: parent.width
                text: qsTr("Confirm")
                onClicked: root.confirmClicked()
            }
        }
    }
}
