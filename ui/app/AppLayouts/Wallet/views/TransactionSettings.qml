import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Core.Theme 0.1

import AppLayouts.Wallet 1.0

import shared.controls 1.0
import shared.popups 1.0
import utils 1.0

import AppLayouts.Wallet 1.0

Rectangle {
    id: root

    required property string currentBaseFee
    required property string currentSuggestedMinPriorityFee
    required property string currentSuggestedMaxPriorityFee
    required property string currentGasAmount
    required property int currentNonce

    property alias normalPrice: optionNormal.subText
    property alias normalTime: optionNormal.additionalText

    property alias fastPrice: optionFast.subText
    property alias fastTime: optionFast.additionalText

    property alias urgentPrice: optionUrgent.subText
    property alias urgentTime: optionUrgent.additionalText

    property alias customBaseFee: customBaseFeeInput.text
    property alias customBaseFeeDirty: customBaseFeeInput.input.dirty
    property alias customPriorityFee: customPriorityFeeInput.text
    property alias customPriorityFeeDirty: customPriorityFeeInput.input.dirty
    property alias customGasAmount: customGasAmountInput.text
    property alias customGasAmountDirty: customGasAmountInput.input.dirty
    property alias customNonce: customNonceInput.text
    property alias customNonceDirty: customNonceInput.input.dirty

    required property int selectedFeeMode

    required property var fnGetPriceInCurrencyForFee
    required property var fnGetEstimatedTime
    required property var fnRawToGas
    required property var fnGasToRaw

    signal confirmClicked()
    signal cancelClicked()

    color: Theme.palette.statusModal.backgroundColor
    radius: Theme.radius

    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    focus: true

    Keys.onReleased: {
        if (event.key === Qt.Key_Escape) {
            root.cancelClicked()
        }
    }

    function recalculateCustomPrice() {
        d.recalculateCustomPrice()
    }

    Component.onCompleted: root.forceActiveFocus()

    QtObject {
        id: d

        readonly property bool customMode: root.selectedFeeMode === Constants.FeePriorityModeType.Custom

        function showAlert(title, text, note, url) {
            infoBox.title = title
            infoBox.text = text
            infoBox.note = note
            infoBox.url = url
            infoBox.active = true
        }

        function recalculateCustomBaseFeePrice() {
            if (!customBaseFeeInput.text) {
                customBaseFeeInput.bottomLabelMessageRightCmp.text = ""
                return
            }
            const rawValue = root.fnGasToRaw(customBaseFeeInput.text).toFixed()
            customBaseFeeInput.bottomLabelMessageRightCmp.text = root.fnGetPriceInCurrencyForFee(rawValue)
        }

        function recalculateCustomPriorityFeePrice() {
            if (!customPriorityFeeInput.text) {
                customPriorityFeeInput.bottomLabelMessageRightCmp.text = ""
                return
            }
            const rawValue = root.fnGasToRaw(customPriorityFeeInput.text).toFixed()
            customPriorityFeeInput.bottomLabelMessageRightCmp.text = root.fnGetPriceInCurrencyForFee(rawValue)
        }

        function recalculateCustomPrice() {
            if (!customBaseFeeInput.text || !customPriorityFeeInput.text || !customGasAmountInput.text) {
                optionCustom.subText = ""
                return
            }
            const rawBaseFee = root.fnGasToRaw(customBaseFeeInput.text)
            const rawPriorityFee = root.fnGasToRaw(customPriorityFeeInput.text)
            const rawTotalFee = SQUtils.AmountsArithmetic.sum(rawBaseFee, rawPriorityFee)
            const rawFee = SQUtils.AmountsArithmetic.times(rawTotalFee, SQUtils.AmountsArithmetic.fromString(customGasAmountInput.text)).toFixed()
            const estimatedTime = root.fnGetEstimatedTime(rawTotalFee.toFixed(), rawPriorityFee.toFixed())
            optionCustom.subText = root.fnGetPriceInCurrencyForFee(rawFee)
            optionCustom.additionalText = WalletUtils.formatEstimatedTime(estimatedTime)
        }
    }

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

            spacing: Theme.padding

            StatusBaseText {
                Layout.preferredWidth: parent.width
                text: qsTr("Transaction settings")
                font.pixelSize: Theme.secondaryAdditionalTextSize
                font.bold: true
                elide: Text.ElideMiddle
            }

            RowLayout {
                id: options
                spacing: 12

                StatusFeeOption {
                    id: optionNormal
                    type: Constants.FeePriorityModeType.Normal
                    mainText: WalletUtils.getFeeTextForFeeMode(type)
                    icon: WalletUtils.getIconForFeeMode(type)
                    selected: root.selectedFeeMode === Constants.FeePriorityModeType.Normal
                    showSubText: true
                    showAdditionalText: true

                    onClicked: root.selectedFeeMode = Constants.FeePriorityModeType.Normal
                }

                StatusFeeOption {
                    id: optionFast
                    type: Constants.FeePriorityModeType.Fast
                    mainText: WalletUtils.getFeeTextForFeeMode(type)
                    icon: WalletUtils.getIconForFeeMode(type)
                    selected: root.selectedFeeMode === Constants.FeePriorityModeType.Fast
                    showSubText: true
                    showAdditionalText: true

                    onClicked: root.selectedFeeMode = Constants.FeePriorityModeType.Fast
                }

                StatusFeeOption {
                    id: optionUrgent
                    type: Constants.FeePriorityModeType.Urgent
                    mainText: WalletUtils.getFeeTextForFeeMode(type)
                    icon: WalletUtils.getIconForFeeMode(type)
                    selected: root.selectedFeeMode === Constants.FeePriorityModeType.Urgent
                    showSubText: true
                    showAdditionalText: true

                    onClicked: root.selectedFeeMode = Constants.FeePriorityModeType.Urgent
                }

                StatusFeeOption {
                    id: optionCustom
                    type: Constants.FeePriorityModeType.Custom
                    mainText: WalletUtils.getFeeTextForFeeMode(type)
                    icon: WalletUtils.getIconForFeeMode(type)
                    selected: root.selectedFeeMode === Constants.FeePriorityModeType.Custom
                    showSubText: !!selected
                    showAdditionalText: !!selected
                    unselectedText: qsTr("Set your own fees & nonce")

                    onClicked: root.selectedFeeMode = Constants.FeePriorityModeType.Custom
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
                        id: customBaseFeeInput

                        readonly property bool displayLowBaseFeeWarning: {
                            if (!customBaseFeeInput.text) {
                                return false
                            }
                            const rawCurrentValue = SQUtils.AmountsArithmetic.fromString(root.currentBaseFee)
                            const decreasedCurrentValue = SQUtils.AmountsArithmetic.times(rawCurrentValue, SQUtils.AmountsArithmetic.fromString("0.9")) // up to -10% is acceptable
                            const rawEnteredValue = root.fnGasToRaw(customBaseFeeInput.text)
                            return decreasedCurrentValue.cmp(rawEnteredValue) === 1
                        }

                        readonly property bool displayHighBaseFeeWarning: {
                            if (!customBaseFeeInput.text) {
                                return false
                            }
                            const rawCurrentValue = SQUtils.AmountsArithmetic.fromString(root.currentBaseFee)
                            const increasedCurrentValue = SQUtils.AmountsArithmetic.times(rawCurrentValue, SQUtils.AmountsArithmetic.fromString("1.2")) // up to 20% higher value is acceptable
                            const rawEnteredValue = root.fnGasToRaw(customBaseFeeInput.text)
                            return rawEnteredValue.cmp(increasedCurrentValue) === 1
                        }

                        Layout.preferredWidth: parent.width
                        Layout.topMargin: 20
                        label: qsTr("Max base fee")
                        labelIcon: "info"
                        labelIconColor: Theme.palette.baseColor1
                        labelIconClickable: true
                        bottomLabelMessageLeftCmp.color: customBaseFeeInput.displayLowBaseFeeWarning
                                                         || customBaseFeeInput.displayHighBaseFeeWarning?
                                                             Theme.palette.miscColor6
                                                           : Theme.palette.baseColor1
                        bottomLabelMessageLeftCmp.text: customBaseFeeInput.displayLowBaseFeeWarning?
                                                            qsTr("Lower than necessary (current %1)").arg(Utils.nativeTokenRawToGas(root.currentBaseFee))
                                                          : customBaseFeeInput.displayHighBaseFeeWarning?
                                                                qsTr("Higher than necessary (current %1)").arg(Utils.nativeTokenRawToGas(root.currentBaseFee))
                                                              : qsTr("Current: %1 GWEI").arg(Utils.nativeTokenRawToGas(root.currentBaseFee))
                        rightPadding: leftPadding
                        input.rightComponent: StatusBaseText {
                            text: "GWEI"
                            color: Theme.palette.baseColor1
                        }

                        validators: [
                            StatusRegularExpressionValidator {
                                regularExpression: Constants.regularExpressions.positiveRealNumbers
                                errorMessage: Constants.errorMessages.positiveRealNumbers
                            }
                        ]

                        onTextChanged: Qt.callLater(() => {
                                                        if (!customBaseFeeInput.valid) {
                                                            return
                                                        }
                                                        d.recalculateCustomBaseFeePrice()
                                                        d.recalculateCustomPrice()
                                                    })

                        onLabelIconClicked: d.showAlert(label,
                                                        qsTr("When your transaction gets included in the block, any difference between your max base fee and the actual base fee will be refunded.\n"),
                                                        qsTr("Note: the ETH amount shown for this value is calculated:\nMax base fee (in GWEI) * Max gas amount"),
                                                        "")
                    }

                    StatusInput {
                        id: customPriorityFeeInput

                        readonly property bool displayHigherPriorityFeeWarning: {
                            if (!customPriorityFeeInput.text) {
                                return false
                            }
                            const rawCurrentValue = SQUtils.AmountsArithmetic.fromString(root.currentSuggestedMaxPriorityFee)
                            const rawEnteredValue = root.fnGasToRaw(customPriorityFeeInput.text)
                            return rawEnteredValue.cmp(rawCurrentValue) === 1
                        }

                        readonly property bool displayHigherThanBaseFeeWarning: {
                            if (!customPriorityFeeInput.text || !customBaseFeeInput.text) {
                                return false
                            }
                            const rawBaseFeeValue = root.fnGasToRaw(customBaseFeeInput.text)
                            const rawEnteredValue = root.fnGasToRaw(customPriorityFeeInput.text)
                            return rawEnteredValue.cmp(rawBaseFeeValue) === 1
                        }

                        Layout.preferredWidth: parent.width
                        label: qsTr("Priority fee")
                        labelIcon: "info"
                        labelIconColor: Theme.palette.baseColor1
                        labelIconClickable: true
                        bottomLabelMessageLeftCmp.color: customPriorityFeeInput.displayHigherThanBaseFeeWarning
                                                         || customPriorityFeeInput.displayHigherPriorityFeeWarning?
                                                             Theme.palette.miscColor6
                                                           : Theme.palette.baseColor1
                        bottomLabelMessageLeftCmp.text: customPriorityFeeInput.displayHigherThanBaseFeeWarning?
                                                            qsTr("Higher than max base fee: %1 GWEI").arg(customBaseFeeInput.text)
                                                          : customPriorityFeeInput.displayHigherPriorityFeeWarning?
                                                                qsTr("Higher than necessary (current %1 - %2)").arg(root.fnRawToGas(root.currentSuggestedMinPriorityFee)).arg(root.fnRawToGas(root.currentSuggestedMaxPriorityFee))
                                                              : qsTr("Current: %1 - %2 GWEI").arg(root.fnRawToGas(root.currentSuggestedMinPriorityFee)).arg(root.fnRawToGas(root.currentSuggestedMaxPriorityFee))
                        rightPadding: leftPadding
                        input.rightComponent: StatusBaseText {
                            text: "GWEI"
                            color: Theme.palette.baseColor1
                        }

                        validators: [
                            StatusRegularExpressionValidator {
                                regularExpression: Constants.regularExpressions.positiveRealNumbers
                                errorMessage: Constants.errorMessages.positiveRealNumbers
                            }
                        ]

                        onTextChanged: Qt.callLater(() => {
                                                        if (!customPriorityFeeInput.valid) {
                                                            return
                                                        }
                                                        d.recalculateCustomPriorityFeePrice()
                                                        d.recalculateCustomPrice()
                                                    })

                        onLabelIconClicked: d.showAlert(label,
                                                        qsTr("AKA miner tip. A voluntary fee you can add to incentivise miners or validators to prioritise your transaction.\n\nThe higher the tip, the faster your transaction is likely to be processed, especially curing periods of higher network congestion.\n"),
                                                        qsTr("Note: the ETH amount shown for this value is calculated: Priority fee (in GWEI) * Max gas amount"),
                                                        "")
                    }

                    StatusInput {
                        id: customGasAmountInput

                        readonly property bool displayTooLowAmountWarning: {
                            if (!customGasAmountInput.text) {
                                return false
                            }
                            const minValue = SQUtils.AmountsArithmetic.fromString(Constants.minGasForTx)
                            const enteredValue = SQUtils.AmountsArithmetic.fromString(customGasAmountInput.text)
                            return minValue.cmp(enteredValue) === 1
                        }

                        readonly property bool displayTooHighAmountWarning: {
                            if (!customGasAmountInput.text) {
                                return false
                            }
                            const maxValue = SQUtils.AmountsArithmetic.fromString(Constants.maxGasForTx)
                            const enteredValue = SQUtils.AmountsArithmetic.fromString(customGasAmountInput.text)
                            return enteredValue.cmp(maxValue) === 1
                        }

                        Layout.preferredWidth: parent.width
                        label: qsTr("Max gas amount")
                        labelIcon: "info"
                        labelIconColor: Theme.palette.baseColor1
                        labelIconClickable: true
                        bottomLabelMessageLeftCmp.color: customGasAmountInput.displayTooLowAmountWarning
                                                         || customGasAmountInput.displayTooHighAmountWarning?
                                                             Theme.palette.dangerColor1
                                                           : Theme.palette.baseColor1
                        bottomLabelMessageLeftCmp.text: customGasAmountInput.displayTooLowAmountWarning?
                                                            qsTr("Too low (should be between %1 and %2)").arg(Constants.minGasForTx).arg(Constants.maxGasForTx)
                                                          : customGasAmountInput.displayTooHighAmountWarning?
                                                                qsTr("Too high (should be between %1 and %2)").arg(Constants.minGasForTx).arg(Constants.maxGasForTx)
                                                              : qsTr("Current: %1").arg(root.currentGasAmount)
                        rightPadding: leftPadding
                        input.rightComponent: StatusBaseText {
                            text: qsTr("UNITS")
                            color: Theme.palette.baseColor1
                        }

                        validators: [
                            StatusRegularExpressionValidator {
                                regularExpression: Constants.regularExpressions.wholeNumbers
                                errorMessage: Constants.errorMessages.wholeNumbers
                            }
                        ]

                        onTextChanged: Qt.callLater(() => {
                                                        if (!customGasAmountInput.valid) {
                                                            return
                                                        }
                                                        d.recalculateCustomPrice()
                                                    })

                        onLabelIconClicked: d.showAlert(qsTr("Gas amount"),
                                                        qsTr("AKA gas limit. Refers to the maximum number of computational steps (or units of gas) that a transaction can consume. It represents the complexity or amount of work required to execute a transaction or smart contract.\n\nThe gas limit is a cap on how much work the transaction can do on the blockchain. If the gas limit is set too low, the transaction may fail due to insufficient gas."),
                                                        "",
                                                        "")
                    }

                    StatusInput {
                        id: customNonceInput

                        readonly property bool displayHighNonceWarning: {
                            if (!customNonceInput.text) {
                                return false
                            }

                            try {
                                const expectedValue = parseInt(root.currentNonce)
                                const enteredValue = parseInt(customNonceInput.text)
                                return enteredValue > expectedValue

                            } catch (e) {
                                return false
                            }
                        }

                        Layout.preferredWidth: parent.width
                        label: qsTr("Nonce")
                        labelIcon: "info"
                        labelIconColor: Theme.palette.baseColor1
                        labelIconClickable: true
                        bottomLabelMessageLeftCmp.color: customNonceInput.displayHighNonceWarning?
                                                             Theme.palette.miscColor6
                                                           : Theme.palette.baseColor1
                        bottomLabelMessageLeftCmp.text: {
                            if (customNonceInput.displayHighNonceWarning) {
                                return qsTr("Higher than suggested nonce of %1").arg(root.currentNonce)
                            }
                            let lastUsedNonce = root.currentNonce - 1
                            if (lastUsedNonce < 0) {
                                lastUsedNonce = "-"
                            }
                            return qsTr("Last transaction: %1").arg(lastUsedNonce)
                        }
                        rightPadding: leftPadding
                        input.leftComponent: input.rightComponent // for the reference to the `input`

                        validators: [
                            StatusRegularExpressionValidator {
                                regularExpression: Constants.regularExpressions.wholeNumbers
                                errorMessage: Constants.errorMessages.wholeNumbers
                            }
                        ]

                        onLabelIconClicked: d.showAlert(label,
                                                        qsTr("Transaction counter ensuring transactions from your account are processed in the correct order and can’t be replayed. Each new transaction increments the nonce by 1, ensuring uniqueness and preventing double-spending.\n\nIf a transaction with a lower nonce is pending, higher nonce transactions will remain in the queue until the earlier one is confirmed."),
                                                        "",
                                                        "")
                    }
                }
            }

            StatusButton {
                Layout.preferredWidth: parent.width
                enabled: !d.customMode
                         || (!customBaseFeeInput.input.dirty || customBaseFeeInput.valid) &&
                         (!customPriorityFeeInput.input.dirty || customPriorityFeeInput.valid) &&
                         (!customGasAmountInput.input.dirty || customGasAmountInput.valid) &&
                         (!customNonceInput.input.dirty || customNonceInput.valid) &&
                         !customGasAmountInput.displayTooHighAmountWarning &&
                         !customGasAmountInput.displayTooLowAmountWarning
                text: qsTr("Confirm")
                onClicked: root.confirmClicked()
            }
        }
    }
}
