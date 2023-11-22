import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import utils 1.0

import AppLayouts.Communities.helpers 1.0
import AppLayouts.Communities.panels 1.0
import AppLayouts.Wallet.controls 1.0
import shared.panels 1.0
import shared.popups 1.0

import SortFilterProxyModel 0.2

StatusScrollView {
    id: root

    property int viewWidth: 560 // by design
    property bool isAssetView: false
    property int validationMode: StatusInput.ValidationMode.OnlyWhenDirty

    property var tokensModel
    property TokenObject token: TokenObject {
        type: root.isAssetView ? Constants.TokenType.ERC20 : Constants.TokenType.ERC721
    }

    // Used for reference validation
    required property var referenceAssetsBySymbolModel
    
    // Used for reference validation when editing a failed deployment
    property string referenceName: ""
    property string referenceSymbol: ""

    // Network related properties:
    property var layer1Networks
    property var layer2Networks

    // Account expected roles: address, name, color, emoji, walletType
    property var accounts

    property string feeText
    property string feeErrorText
    property bool isFeeLoading

    readonly property string feeLabel:
        isAssetView ? qsTr("Mint asset on %1").arg(root.token.chainName)
                    : qsTr("Mint collectible on %1").arg(root.token.chainName)

    signal chooseArtWork
    signal previewClicked

    QtObject {
        id: d

        readonly property bool isFullyFilled: dropAreaItem.artworkSource.toString().length > 0
                                              && nameInput.valid
                                              && descriptionInput.valid
                                              && symbolInput.valid
                                              && (unlimitedSupplyChecker.checked || (!unlimitedSupplyChecker.checked && parseInt(supplyInput.text) > 0))
                                              && (!root.isAssetView  || (root.isAssetView && assetDecimalsInput.valid))
                                              && deployFeeSubscriber.feeText !== "" && deployFeeSubscriber.feeErrorText === ""

        readonly property int imageSelectorRectWidth: root.isAssetView ? 128 : 290

        readonly property bool containsAssetReferenceName: root.isAssetView ? checkNameProxy.count > 0 : false
        readonly property SortFilterProxyModel checkNameProxy : SortFilterProxyModel {
          sourceModel: root.referenceAssetsBySymbolModel
          filters: ValueFilter {
            roleName: "name"
            value: nameInput.text
          }
        }

        readonly property bool containsAssetReferenceSymbol: root.isAssetView ? checkSymbolProxy.count > 0 : false
        readonly property SortFilterProxyModel checkSymbolProxy: SortFilterProxyModel {
          sourceModel: root.referenceAssetsBySymbolModel
          filters: ValueFilter {
            roleName: "symbol"
            value: symbolInput.text
          }
        }

        function hasEmoji(text) {
            return SQUtils.Emoji.hasEmoji(SQUtils.Emoji.parse(text));
        }
    }

    padding: 0
    contentWidth: mainLayout.width
    contentHeight: mainLayout.height

    ColumnLayout {
        id: mainLayout

        width: root.viewWidth
        spacing: Style.current.padding

        StatusBaseText {
            elide: Text.ElideRight
            font.pixelSize: Theme.primaryTextFontSize
            text: root.isAssetView ? qsTr("Icon") : qsTr("Artwork")
        }

        DropAndEditImagePanel {
            id: dropAreaItem

            Layout.fillWidth: true
            Layout.preferredHeight: d.imageSelectorRectWidth
            dataImage: root.token.artworkSource
            artworkSource: root.token.artworkSource
            editorAnchorLeft: false
            editorRoundedImage: root.isAssetView
            uploadTextLabel.uploadText: root.isAssetView ? qsTr("Upload") : qsTr("Drag and Drop or Upload Artwork")
            uploadTextLabel.additionalText: qsTr("Images only")
            uploadTextLabel.showAdditionalInfo: !root.isAssetView
            editorTitle: root.isAssetView ? qsTr("Asset icon") : qsTr("Collectible artwork")
            acceptButtonText: root.isAssetView ? qsTr("Upload asset icon") : qsTr("Upload collectible artwork")

            onArtworkSourceChanged: root.token.artworkSource = artworkSource
            onArtworkCropRectChanged: root.token.artworkCropRect = artworkCropRect
        }

        CustomStatusInput {
            id: nameInput

            label: qsTr("Name")
            text: root.token.name
            charLimit: 15
            placeholderText: qsTr("Name")
            validationMode: root.validationMode
            minLengthValidator.errorMessage: qsTr("Please name your token name (use A-Z and 0-9, hyphens and underscores only)")
            regexValidator.errorMessage: d.hasEmoji(text) ?
                                             qsTr("Your token name is too cool (use A-Z and 0-9, hyphens and underscores only)") :
                                             qsTr("Your token name contains invalid characters (use A-Z and 0-9, hyphens and underscores only)")
            extraValidator.validate: function (value) {
                // If minting failed, we can retry same deployment, so same name allowed
                const allowRepeatedName = root.token.deployState === Constants.ContractTransactionStatus.Failed
                if(allowRepeatedName)
                    if(nameInput.text === root.referenceName)
                        return true

                // Otherwise, no repeated names allowed:
                return (!SQUtils.ModelUtils.contains(root.tokensModel, "name", nameInput.text, Qt.CaseInsensitive) && !d.containsAssetReferenceName)
            }
            extraValidator.errorMessage: d.containsAssetReferenceName ? qsTr("Asset name already exists") :
                                                                        qsTr("You have used this token name before")

            onTextChanged: root.token.name = text
        }

        CustomStatusInput {
            id: descriptionInput

            label: qsTr("Description")
            text: root.token.description
            charLimit: 280
            placeholderText: root.isAssetView ? qsTr("Describe your asset (will be shown in hodler’s wallets)") : qsTr("Describe your collectible (will be shown in hodler’s wallets)")
            input.multiline: true
            input.verticalAlignment: Qt.AlignTop
            input.placeholder.verticalAlignment: Qt.AlignTop
            minimumHeight: 108
            maximumHeight: minimumHeight
            validationMode: root.validationMode
            minLengthValidator.errorMessage: qsTr("Please enter a token description")
            regexValidator.regularExpression: Constants.regularExpressions.ascii
            regexValidator.errorMessage: qsTr("Only A-Z, 0-9 and standard punctuation allowed")

            onTextChanged: root.token.description
        }

        CustomStatusInput {
            id: symbolInput

            label: qsTr("Symbol")
            text: root.token.symbol
            charLimit: 6
            placeholderText: root.isAssetView ? qsTr("e.g. ETH"): qsTr("e.g. DOODLE")
            validationMode: root.validationMode
            minLengthValidator.errorMessage: qsTr("Please enter your token symbol (use A-Z only)")
            regexValidator.errorMessage: d.hasEmoji(text) ? qsTr("Your token symbol is too cool (use A-Z only)") :
                                                            qsTr("Your token symbol contains invalid characters (use A-Z only)")
            regexValidator.regularExpression: Constants.regularExpressions.capitalOnly
            extraValidator.validate: function (value) {
                // If minting failed, we can retry same deployment, so same symbol allowed
                const allowRepeatedName = root.token.deployState === Constants.ContractTransactionStatus.Failed
                if(allowRepeatedName)
                    if(symbolInput.text.toUpperCase() === root.referenceSymbol.toUpperCase())
                        return true

                // Otherwise, no repeated names allowed:
                return (!SQUtils.ModelUtils.contains(root.tokensModel, "symbol", symbolInput.text) && !d.containsAssetReferenceSymbol)
            }
            extraValidator.errorMessage: d.containsAssetReferenceSymbol ? qsTr("Symbol already exists") : qsTr("You have used this token symbol before")

            onTextChanged: {
                const cursorPos = input.edit.cursorPosition
                const upperSymbol = text.toUpperCase()
                root.token.symbol = upperSymbol
                text = upperSymbol // breaking the binding on purpose but so does validate() and onTextChanged() internal handler
                input.edit.cursorPosition = cursorPos
            }
        }

        StatusBaseText {
            text: qsTr("Network")
            color: Theme.palette.directColor1
            font.pixelSize: Theme.primaryTextFontSize
        }

        Rectangle {
            Layout.preferredHeight: 44
            Layout.fillWidth: true
            radius: 8
            color: "transparent"
            border.color: Theme.palette.directColor7

            RowLayout {
                id: networkRow

                anchors.verticalCenter: parent.verticalCenter
                spacing: 16

                StatusSmartIdenticon {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: Style.current.padding

                    asset.height: 24
                    asset.width: asset.height
                    asset.isImage: true
                    asset.name: Style.svg(token.chainIcon)
                    active: true
                    visible: active
                }

                StatusBaseText {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                    Layout.rightMargin: Style.current.padding

                    font.pixelSize: 13
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    lineHeight: 24
                    lineHeightMode: Text.FixedHeight
                    verticalAlignment: Text.AlignVCenter
                    text: token.chainName
                    color: Theme.palette.baseColor1
                    visible: !!text
                }
            }
        }

        CustomSwitchRowComponent {
            id: unlimitedSupplyChecker

            label: qsTr("Unlimited supply")
            description: qsTr("Enable to allow the minting of additional tokens in the future. Disable to specify a finite supply")
            checked: root.token.infiniteSupply

            onCheckedChanged: {
                if(!checked) supplyInput.forceActiveFocus()

                root.token.infiniteSupply = checked
            }
        }

        CustomStatusInput {
            id: supplyInput

            visible: !unlimitedSupplyChecker.checked
            label: qsTr("Total finite supply")
            text: SQUtils.AmountsArithmetic.toNumber(root.token.supply,
                                                     root.token.multiplierIndex)

            placeholderText: qsTr("e.g. 300")
            minLengthValidator.errorMessage: qsTr("Please enter a total finite supply")
            regexValidator.errorMessage: d.hasEmoji(text) ? qsTr("Your total finite supply is too cool (use 0-9 only)") :
                                                            qsTr("Your total finite supply contains invalid characters (use 0-9 only)")
            regexValidator.regularExpression: Constants.regularExpressions.numerical
            extraValidator.validate: function (value) { return parseInt(value) > 0 && parseInt(value) <= 999999999 }
            extraValidator.errorMessage: qsTr("Enter a number between 1 and 999,999,999")

            onTextChanged: {
                const supplyNumber = parseInt(text)
                if (Number.isNaN(supplyNumber) || Object.values(errors).length)
                    return

                token.supply = SQUtils.AmountsArithmetic.fromNumber(
                            supplyNumber, root.token.multiplierIndex).toFixed(0)
            }
        }

        CustomSwitchRowComponent {
            id: transferableChecker

            visible: !root.isAssetView
            label: checked ? qsTr("Not transferable (Soulbound)") : qsTr("Transferable")
            description: qsTr("If enabled, the token is locked to the first address it is sent to and can never be transferred to another address. Useful for tokens that represent Admin permissions")
            checked: !root.token.transferable

            onCheckedChanged: root.token.transferable = !checked
        }

        CustomSwitchRowComponent {
            id: remotelyDestructChecker

            visible: !root.isAssetView
            label: qsTr("Remotely destructible")
            description: qsTr("Enable to allow you to destroy tokens remotely. Useful for revoking permissions from individuals")
            checked: !!root.token ? root.token.remotelyDestruct : true
            onCheckedChanged: root.token.remotelyDestruct = checked
        }

        CustomStatusInput {
            id: assetDecimalsInput

            visible: root.isAssetView
            label: qsTr("Decimals (DP)")
            charLimit: 2
            charLimitLabel: qsTr("Max 10")
            placeholderText: "2"
            text: root.token.decimals
            validationMode: StatusInput.ValidationMode.Always
            minLengthValidator.errorMessage: qsTr("Please enter how many decimals your token should have")
            regexValidator.errorMessage: d.hasEmoji(text) ? qsTr("Your decimal amount is too cool (use 0-9 only)") :
                                                            qsTr("Your decimal amount contains invalid characters (use 0-9 only)")
            regexValidator.regularExpression: Constants.regularExpressions.numerical
            extraValidator.validate: function (value) { return parseInt(value) > 0 && parseInt(value) <= 10 }
            extraValidator.errorMessage: qsTr("Enter a number between 1 and 10")
            onTextChanged: root.token.decimals = parseInt(text)
        }

        FeesBox {
            id: feesBox

            Layout.fillWidth: true
            Layout.topMargin: Style.current.padding

            accountErrorText: root.feeErrorText
            implicitWidth: 0

            model: QtObject {
                id: singleFeeModel

                readonly property string title: root.feeLabel
                readonly property string feeText: root.isFeeLoading ?
                                                      "" : root.feeText
                readonly property bool error: root.feeErrorText !== ""
            }

            accountsSelector.model: root.accounts

            // account can be changed also on preview page and it should be
            // reflected in the form after navigating back
            Connections {
                target: root.token

                function onAccountAddressChanged() {
                    const idx = SQUtils.ModelUtils.indexOf(
                                  feesBox.accountsSelector.model, "address",
                                  root.token.accountAddress)

                    feesBox.accountsSelector.currentIndex = idx
                }
            }

            accountsSelector.onCurrentIndexChanged: {
                if (accountsSelector.currentIndex < 0)
                    return

                const item = SQUtils.ModelUtils.get(
                               accountsSelector.model, accountsSelector.currentIndex)
                root.token.accountAddress = item.address
                root.token.accountName = item.name
            }
        }

        StatusButton {
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.topMargin: Style.current.padding
            Layout.bottomMargin: Style.current.padding
            text: qsTr("Preview")
            enabled: d.isFullyFilled

            onClicked: root.previewClicked()
        }
    }

    // Inline components definition:
    component CustomStatusInput: StatusInput {
        id: customInput

        property alias minLengthValidator: minLengthValidatorItem
        property alias regexValidator: regexValidatorItem
        property alias extraValidator: extraValidatorItem

        Layout.fillWidth: true
        validators: [
            StatusMinLengthValidator {
                id: minLengthValidatorItem
                minLength: 1
            },
            StatusRegularExpressionValidator {
                id: regexValidatorItem
                regularExpression: Constants.regularExpressions.alphanumericalExpanded
                onErrorMessageChanged: {
                    customInput.validate();
                }
            },
            StatusValidator {
                id: extraValidatorItem
                onErrorMessageChanged: {
                    customInput.validate();
                }
            }
        ]
    }

    component CustomLabelDescriptionComponent: ColumnLayout {
        id: labelDescComponent

        property string label
        property string description

        Layout.fillWidth: true

        StatusBaseText {
            text: labelDescComponent.label
            color: Theme.palette.directColor1
            font.pixelSize: Theme.primaryTextFontSize
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: labelDescComponent.description
            color: Theme.palette.baseColor1
            font.pixelSize: Theme.primaryTextFontSize
            lineHeight: 1.2
            wrapMode: Text.WordWrap
        }
    }

    component CustomSwitchRowComponent: RowLayout {
        id: rowComponent

        property string label
        property string description
        property alias checked: switch_.checked

        Layout.fillWidth: true
        Layout.topMargin: Style.current.padding
        spacing: 64

        CustomLabelDescriptionComponent {
            label: rowComponent.label
            description: rowComponent.description
        }

        StatusSwitch {
            id: switch_
        }
    }
}
