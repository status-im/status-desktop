import QtQuick 2.15
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14
import QtGraphicalEffects 1.0
import QtQml 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Controls.Validators 0.1
import StatusQ.Components 0.1

import AppLayouts.Communities.panels 1.0
import AppLayouts.Communities.helpers 1.0

import utils 1.0
import SortFilterProxyModel 0.2

StatusDialog {
    id: root

    property string communityName
    property bool isAsset // If asset isAsset = true; if collectible --> isAsset = false
    property string tokenName
    property int remainingTokens
    property url tokenSource
    property string chainName

    // Fees related properties:
    property string feeText
    property string feeErrorText: ""
    property bool isFeeLoading
    readonly property string feeLabel: qsTr("Burn %1 token on %2").arg(root.tokenName).arg(root.chainName)

    // Account expected roles: address, name, color, emoji, walletType
    property var accounts

    signal burnClicked(int burnAmount, string accountAddress)
    signal cancelClicked
    signal burnFeesRequested(int burnAmount, string accountAddress)

    QtObject {
        id: d

        property string accountAddress
        property alias amountToBurn: amountToBurnInput.text
        readonly property bool isFeeError: root.feeErrorText !== ""
        readonly property bool isFormValid: specificAmountButton.checked && amountToBurnInput.valid || allTokensButton.checked
        property bool isInitialized: false

        function initialize() {
            specificAmountButton.checked = true
            isInitialized = true
            amountToBurnInput.forceActiveFocus()
        }

        function getVerticalPadding() {
            return root.topPadding + root.bottomPadding
        }

        function getHorizontalPadding() {
            return root.leftPadding + root.rightPadding
        }
    }

    implicitWidth: 600 // by design
    implicitHeight: content.implicitHeight + footer.height + header.height + d.getVerticalPadding()

    contentItem: ColumnLayout {
        id: content

        spacing: Style.current.padding

        StatusBaseText {
            Layout.fillWidth: true

            text: qsTr("How many of %1’s remaining %n %2 tokens would you like to burn?", "", root.remainingTokens).arg(root.communityName).arg(root.tokenName)
            wrapMode: Text.WordWrap
            lineHeight: 1.2
            font.pixelSize: Style.current.primaryTextFontSize
        }

        RowLayout {
            Layout.bottomMargin: 12
            Layout.leftMargin: -Style.current.halfPadding

            spacing: 26

            ColumnLayout {
                StatusRadioButton {
                    id: specificAmountButton

                    text: qsTr("Specific amount")
                    font.pixelSize: Style.current.primaryTextFontSize
                    ButtonGroup.group: radioGroup

                    onToggled: if(checked) amountToBurnInput.forceActiveFocus()
                }

                StatusInput {
                    id: amountToBurnInput

                    Layout.preferredWidth: 192
                    Layout.leftMargin: 30
                    enabled: specificAmountButton.checked
                    validationMode: StatusInput.ValidationMode.OnlyWhenDirty
                    validators: [
                        StatusValidator {
                            validate: (value) => { return (parseInt(value) > 0 && parseInt(value) <= root.remainingTokens) }
                            errorMessage: qsTr("Exceeds available remaining")
                        },
                        StatusValidator {
                            validate: (value) => { return parseInt(value) !== 0 }
                            errorMessage: qsTr("Amount must be greater than 0")
                        },
                        StatusRegularExpressionValidator {
                            regularExpression: Constants.regularExpressions.numerical
                            errorMessage: qsTr("Invalid characters (0-9 only)")
                        }
                    ]
                }
            }

            StatusRadioButton {
                id: allTokensButton

                Layout.alignment: Qt.AlignTop

                text: qsTr("All available remaining (%1)").arg(root.remainingTokens)
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

            readonly property bool triggerFeeReevaluation: {
                specificAmountButton.checked
                amountToBurnInput.text
                allTokensButton.checked
                feesBox.accountsSelector.currentIndex
                if (d.isInitialized) {
                    requestFeeDelayTimer.restart()
                }
                return true
            }

            Layout.fillWidth: true

            placeholderText: qsTr("Choose number of tokens to burn to see gas fees")
            accountErrorText: root.feeErrorText
            implicitWidth: 0
            model: d.isFormValid ? singleFeeModel : undefined
            accountsSelector.model: root.accounts

            accountsSelector.onCurrentIndexChanged: {
                if (accountsSelector.currentIndex < 0)
                    return

                const item = SQUtils.ModelUtils.get(accountsSelector.model, accountsSelector.currentIndex)
                d.accountAddress = item.address
            }

            Timer {
                id: requestFeeDelayTimer
                interval: 500
                onTriggered: {
                    if(specificAmountButton.checked)
                        root.burnFeesRequested(parseInt(amountToBurnInput.text), d.accountAddress)
                    else
                        root.burnFeesRequested(root.remainingTokens, d.accountAddress)
                }
            }

            QtObject {
                id: singleFeeModel

                readonly property string title: root.feeLabel
                readonly property string feeText: root.isFeeLoading ?
                                                      "" : root.feeText
                readonly property bool error: d.isFeeError
            }
        }
    }

    header: StatusDialogHeader {
        headline.title: qsTr("Burn %1 tokens").arg(root.tokenName)
        headline.subtitle: qsTr("%n %1 remaining in smart contract", "", root.remainingTokens).arg(root.tokenName)
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
                text: qsTr("Burn tokens")
                type: StatusBaseButton.Type.Danger
                onClicked: {
                    if(specificAmountButton.checked)
                        root.burnClicked(parseInt(amountToBurnInput.text), d.accountAddress)
                    else
                        root.burnClicked(root.remainingTokens, d.accountAddress)
                }
            }
        }
    }

    onOpened: d.initialize()
    onClosed: d.isInitialized = false
}
