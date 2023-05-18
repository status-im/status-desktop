import QtQuick 2.15
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Components 0.1

import AppLayouts.Chat.panels.communities 1.0

import utils 1.0

StatusDialog {
    id: root

    property string communityName
    property string tokenName
    property int remainingTokens
    property url tokenSource
    property bool isAsset // If asset isAsset = true; if collectible --> isAsset = false

    signal burnClicked(int burnAmount)
    signal cancelClicked

    QtObject {
        id: d

        property alias amountToBurn: amountToBurnInput.text

        function initialize() {
            specificAmountButton.checked = true
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
                enabled: specificAmountButton.checked && amountToBurnInput.valid || allTokensButton.checked
                text: qsTr("Burn tokens")
                type: StatusBaseButton.Type.Danger
                onClicked: {
                    if(specificAmountButton.checked)
                        root.burnClicked(parseInt(amountToBurnInput.text))
                    else
                        root.burnClicked(root.remainingTokens)
                }
            }
        }
    }

    onOpened: d.initialize()
}
