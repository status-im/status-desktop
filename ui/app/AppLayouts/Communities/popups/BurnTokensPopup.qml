import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import AppLayouts.Communities.panels 1.0

import utils 1.0
import shared.controls 1.0


StatusDialog {
    id: root

    property string communityName
    property bool isAsset // If asset isAsset = true; if collectible --> isAsset = false
    property string tokenName
    property string remainingTokens
    property int multiplierIndex
    property url tokenSource
    property string chainName

    readonly property alias amountToBurn: d.amountToBurn
    readonly property alias selectedAccountAddress: d.accountAddress
    
    // Fees related properties:
    property string feeText
    property string feeErrorText: ""
    property bool isFeeLoading
    readonly property string feeLabel: qsTr("Burn %1 token on %2").arg(root.tokenName).arg(root.chainName)

    // Account expected roles: address, name, color, emoji, walletType
    property var accounts

    signal burnClicked(string burnAmount, string accountAddress)
    signal cancelClicked

    QtObject {
        id: d

        readonly property real remainingTokensFloat:
            SQUtils.AmountsArithmetic.toNumber(
                root.remainingTokens, root.multiplierIndex)

        readonly property string remainingTokensDisplayText:
            LocaleUtils.numberToLocaleString(remainingTokensFloat)

        property string accountAddress
        property string amountToBurn: !isFormValid ? "" :
                                        specificAmountButton.checked ? amountInput.amount : root.remainingTokens

        readonly property bool isFeeError: root.feeErrorText !== ""

        readonly property bool isFormValid:
            (specificAmountButton.checked && amountInput.valid && amountInput.text)
            || allTokensButton.checked

        function initialize() {
            specificAmountButton.checked = true
            amountInput.forceActiveFocus()
        }

        function getVerticalPadding() {
            return root.topPadding + root.bottomPadding
        }

        function getHorizontalPadding() {
            return root.leftPadding + root.rightPadding
        }
    }

    width: 600 // by design
    implicitHeight: content.implicitHeight + footer.height + header.height + d.getVerticalPadding()

    contentItem: ColumnLayout {
        id: content

        spacing: Style.current.padding

        StatusBaseText {
            Layout.fillWidth: true

            text: {
                if (Number.isInteger(d.remainingTokensFloat))
                    return qsTr("How many of %1’s remaining %Ln %2 token(s) would you like to burn?",
                                "", d.remainingTokensFloat).arg(root.communityName).arg(root.tokenName)

                return qsTr("How many of %1’s remaining %2 %3 tokens would you like to burn?")
                    .arg(root.communityName).arg(d.remainingTokensDisplayText).arg(root.tokenName)
            }

            wrapMode: Text.WordWrap
            lineHeight: 1.2
            font.pixelSize: Style.current.primaryTextFontSize
        }

        Item {
            Layout.bottomMargin: 12
            Layout.leftMargin: -Style.current.halfPadding
            Layout.fillWidth: true

            implicitHeight: childrenRect.height

            readonly property int spacing: 26

            ColumnLayout {
                id: specificAmountColumn

                StatusRadioButton {
                    id: specificAmountButton

                    Layout.preferredWidth: amountInput.Layout.preferredWidth
                                           + amountInput.Layout.leftMargin

                    text: qsTr("Specific amount")
                    font.pixelSize: Style.current.primaryTextFontSize
                    ButtonGroup.group: radioGroup

                    onToggled: if(checked) amountInput.forceActiveFocus()
                }

                AmountInput {
                    id: amountInput

                    Layout.preferredWidth: 192
                    Layout.leftMargin: 30
                    customHeight: 44

                    allowDecimals: root.multiplierIndex > 0
                    maximumAmount: root.remainingTokens
                    multiplierIndex: root.multiplierIndex

                    validateMaximumAmount: true
                    allowZero: false

                    placeholderText: qsTr("Enter amount")
                    labelText: ""

                    maximumExceededErrorText: qsTr("Exceeds available remaining")
                }
            }

            StatusRadioButton {
                id: allTokensButton

                anchors.left: specificAmountColumn.right
                anchors.right: parent.right
                anchors.leftMargin: parent.spacing

                text: qsTr("All available remaining (%1)").arg(d.remainingTokensDisplayText)
                font.pixelSize: Style.current.primaryTextFontSize
                ButtonGroup.group: radioGroup
            }

            ButtonGroup { id: radioGroup }
        }

        StatusDialogDivider {
            Layout.fillWidth: true
        }

        FeesBox {
            id: feesBox
            Layout.fillWidth: true

            placeholderText: qsTr("Choose number of tokens to burn to see gas fees")
            accountErrorText: root.feeErrorText
            implicitWidth: 0
            model: d.isFormValid ? singleFeeModel : undefined
            accountsSelector.model: root.accounts

            accountsSelector.onCurrentIndexChanged: {
                if (accountsSelector.currentIndex < 0)
                    return

                const item = SQUtils.ModelUtils.get(
                               accountsSelector.model,
                               accountsSelector.currentIndex)

                d.accountAddress = item.address
            }

            QtObject {
                id: singleFeeModel

                readonly property string title: root.feeLabel
                readonly property string feeText: root.isFeeLoading
                                                  ? "" : root.feeText
                readonly property bool error: d.isFeeError
            }
        }
    }

    header: StatusDialogHeader {
        headline.title: qsTr("Burn %1 tokens").arg(root.tokenName)
        headline.subtitle: qsTr("%1 %2 remaining in smart contract")
            .arg(d.remainingTokensDisplayText).arg(root.tokenName)

        leftComponent: Rectangle {
            height: 40
            width: height
            radius: root.isAsset ? height/2 : 8
            color:Theme.palette.baseColor2

            Image {
                id: image

                source: root.tokenSource
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                visible: false
            }

            OpacityMask {
                anchors.fill: image
                source: image
                maskSource: parent
            }
        }
        actions.closeButton.onClicked: root.close()
    }

    footer: StatusDialogFooter {
        spacing: Style.current.padding
        rightButtons: ObjectModel {
            StatusButton {
                text: qsTr("Cancel")
                normalColor: "transparent"

                onClicked: {
                    root.cancelClicked()
                    close()
                }
            }

            StatusButton {
                enabled: d.isFormValid && !d.isFeeError && !root.isFeeLoading
                         && root.feeText !== ""
                text: qsTr("Burn tokens")
                type: StatusBaseButton.Type.Danger

                onClicked: {
                    if (specificAmountButton.checked)
                        root.burnClicked(amountInput.amount, d.accountAddress)
                    else
                        root.burnClicked(root.remainingTokens, d.accountAddress)
                }
            }
        }
    }

    onOpened: d.initialize()
}
