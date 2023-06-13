import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import utils 1.0

import AppLayouts.Chat.helpers 1.0
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

    property CollectibleObject collectible: CollectibleObject{}
    property AssetObject asset: AssetObject{}

    // Used for reference validation when editing a failed deployment
    property string referenceName: ""
    property string referenceSymbol: ""

    // Network related properties:
    property var layer1Networks
    property var layer2Networks
    property var testNetworks
    property var enabledNetworks
    property var allNetworks

    // Account expected roles: address, name, color, emoji
    property var accounts

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

        readonly property int imageSelectorRectWidth: root.isAssetView ? 128 : 290
    }

    padding: 0

    Component.onCompleted: {
        if(root.isAssetView)
            networkSelector.setChain(asset.chainId)
        else
            networkSelector.setChain(collectible.chainId)
    }

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
            dataImage: root.isAssetView ? asset.artworkSource : collectible.artworkSource
            artworkSource: root.isAssetView ? asset.artworkSource : collectible.artworkSource
            editorAnchorLeft: !root.isAssetView
            editorRoundedImage: root.isAssetView
            uploadTextLabel.uploadText: root.isAssetView ? qsTr("Upload") : qsTr("Drag and Drop or Upload Artwork")
            uploadTextLabel.additionalText: qsTr("Images only")
            uploadTextLabel.showAdditionalInfo: !root.isAssetView
            editorTitle: root.isAssetView ? qsTr("Asset icon") : qsTr("Collectible artwork")
            acceptButtonText: root.isAssetView ? qsTr("Upload asset icon") : qsTr("Upload collectible artwork")

            onArtworkSourceChanged: {
                if(root.isAssetView)
                    asset.artworkSource = artworkSource
                else
                    collectible.artworkSource = artworkSource
            }
            onArtworkCropRectChanged: {
                if(root.isAssetView)
                    asset.artworkCropRect = artworkCropRect
                else
                    collectible.artworkCropRect = artworkCropRect
            }
        }

        CustomStatusInput {
            id: nameInput

            label: qsTr("Name")
            text: root.isAssetView ? asset.name : collectible.name
            charLimit: 15
            placeholderText: qsTr("Name")
            validationMode: root.validationMode
            minLengthValidator.errorMessage: qsTr("Please name your token name (use A-Z and 0-9, hyphens and underscores only)")
            regexValidator.errorMessage: qsTr("Your token name contains invalid characters (use A-Z and 0-9, hyphens and underscores only)")
            extraValidator.validate: function (value) {
                // If minted failed, we can retry same deployment, so same name allowed
                var allowRepeatedName = (root.isAssetView ? asset.deployState : collectible.deployState) === Constants.ContractTransactionStatus.Failed
                if(allowRepeatedName)
                    if(nameInput.text === root.referenceName)
                        return true

                // Otherwise, no repeated names allowed:
                return !SQUtils.ModelUtils.contains(root.tokensModel, "name", nameInput.text)
            }
            extraValidator.errorMessage: qsTr("You have used this token name before")

            onTextChanged: {
                if(root.isAssetView)
                    asset.name = text
                else
                    collectible.name = text
            }
        }

        CustomStatusInput {
            id: descriptionInput

            label: qsTr("Description")
            text: root.isAssetView ? asset.description : collectible.description
            charLimit: 280
            placeholderText: root.isAssetView ? qsTr("Describe your asset") : qsTr("Describe your collectible")
            input.multiline: true
            input.verticalAlignment: Qt.AlignTop
            input.placeholder.verticalAlignment: Qt.AlignTop
            minimumHeight: 108
            maximumHeight: minimumHeight
            validationMode: root.validationMode
            minLengthValidator.errorMessage: qsTr("Please enter a token description")
            regexValidator.regularExpression: Constants.regularExpressions.ascii
            regexValidator.errorMessage: qsTr("Only A-Z, 0-9 and standard punctuation allowed")

            onTextChanged: {
                if(root.isAssetView)
                    asset.description = text
                else
                    collectible.description = text
            }
        }

        CustomStatusInput {
            id: symbolInput

            label: qsTr("Symbol")
            text: root.isAssetView ? asset.symbol : collectible.symbol
            charLimit: 6
            placeholderText: qsTr("e.g. DOODLE")
            validationMode: root.validationMode
            minLengthValidator.errorMessage: qsTr("Please enter your token symbol (use A-Z only)")
            regexValidator.errorMessage: qsTr("Your token symbol contains invalid characters (use A-Z only)")
            regexValidator.regularExpression: Constants.regularExpressions.capitalOnly
            extraValidator.validate: function (value) {
                // If minted failed, we can retry same deployment, so same symbol allowed
                var allowRepeatedName = (root.isAssetView ? asset.deployState : collectible.deployState) === Constants.ContractTransactionStatus.Failed
                if(allowRepeatedName)
                    if(symbolInput.text === root.referenceSymbol)
                        return true

                // Otherwise, no repeated names allowed:
                return !SQUtils.ModelUtils.contains(root.tokensModel, "symbol", symbolInput.text)
            }
            extraValidator.errorMessage: qsTr("You have used this token symbol before")

            onTextChanged: {
                if(root.isAssetView)
                    asset.symbol = text
                else
                    collectible.symbol = text
            }
        }

        CustomLabelDescriptionComponent {
            Layout.topMargin: Style.current.padding
            label: qsTr("Select account")
            description: qsTr("Account will be required for all subsequent interactions with this token. Remember everybody in your community will be able to see this address.")
        }

        StatusEmojiAndColorComboBox {
            id: accountBox

            readonly property string address: SQUtils.ModelUtils.get(root.accounts, currentIndex, "address")
            readonly property string initAccountName: root.isAssetView ? asset.accountName : collectible.accountName
            readonly property int initIndex: SQUtils.ModelUtils.indexOf(root.accounts, "name", initAccountName)

            Layout.fillWidth: true

            currentIndex: (initIndex !== -1) ? initIndex : 0
            model: SortFilterProxyModel {
                sourceModel: root.accounts
                proxyRoles: [
                    ExpressionRole {
                        name: "color"

                        function getColor(colorId) {
                            return Utils.getColorForId(colorId)
                        }

                        // Direct call for singleton function is not handled properly by
                        // SortFilterProxyModel that's why helper function is used instead.
                        expression: { return getColor(model.colorId) }
                    }
                ]
            }
            type: StatusComboBox.Type.Secondary
            size: StatusComboBox.Size.Small
            implicitHeight: 44
            defaultAssetName: "filled-account"

            onAddressChanged: {
                if(root.isAssetView)
                    asset.accountAddress = address
                else
                    collectible.accountAddress = address
            }
            control.onDisplayTextChanged: {
                if(root.isAssetView)
                    asset.accountName = control.displayText
                else
                    collectible.accountName = control.displayText
            }
        }

        CustomNetworkFilterRowComponent {
            id: networkSelector

            label: qsTr("Select network")
            description: qsTr("The network on which this token will be minted")
        }

        CustomSwitchRowComponent {
            id: unlimitedSupplyChecker

            label: qsTr("Unlimited supply")
            description: qsTr("Enable to allow the minting of additional tokens in the future. Disable to specify a finite supply")
            checked: root.isAssetView ? asset.infiniteSupply : collectible.infiniteSupply

            onCheckedChanged: {
                if(!checked) supplyInput.forceActiveFocus()

                if(root.isAssetView)
                    asset.infiniteSupply = checked
                else
                    collectible.infiniteSupply = checked
            }
        }

        CustomStatusInput {
            id: supplyInput

            visible: !unlimitedSupplyChecker.checked
            label: qsTr("Total finite supply")
            text: root.isAssetView ? asset.supply : collectible.supply
            placeholderText: qsTr("e.g. 300")
            minLengthValidator.errorMessage: qsTr("Please enter a total finite supply")
            regexValidator.errorMessage: qsTr("Your total finite supply contains invalid characters (use 0-9 only)")
            regexValidator.regularExpression: Constants.regularExpressions.numerical
            extraValidator.validate: function (value) { return  parseInt(value) > 0 && parseInt(value) <= 999999999 }
            extraValidator.errorMessage: qsTr("Enter a number between 0 and 999,999,999")

            onTextChanged: {
                if(root.isAssetView)
                    asset.supply = parseInt(text)
                else
                    collectible.supply = parseInt(text)
            }
        }

        CustomSwitchRowComponent {
            id: transferableChecker

            visible: !root.isAssetView
            label: checked ? qsTr("Not transferable (Soulbound)") : qsTr("Transferable")
            description: qsTr("If enabled, the token is locked to the first address it is sent to and can never be transferred to another address. Useful for tokens that represent Admin permissions")
            checked: !collectible.transferable

            onCheckedChanged: collectible.transferable = !checked
        }

        CustomSwitchRowComponent {
            id: remotelyDestructChecker

            visible: !root.isAssetView
            label: qsTr("Remotely destructible")
            description: qsTr("Enable to allow you to destroy tokens remotely. Useful for revoking permissions from individuals")
            checked: !!collectible ? collectible.remotelyDestruct : true
            onCheckedChanged: collectible.remotelyDestruct = checked
        }

        CustomStatusInput {
            id: assetDecimalsInput

            visible: root.isAssetView
            label: qsTr("Decimals (DP)")
            charLimit: 2
            charLimitLabel: qsTr("Max 10")
            placeholderText: "2"
            text: !!asset ? asset.decimals : ""
            validationMode: StatusInput.ValidationMode.Always
            minLengthValidator.errorMessage: qsTr("Please enter how many decimals your token should have")
            regexValidator.errorMessage: qsTr("Your decimal amount contains invalid characters (use 0-9 only)")
            regexValidator.regularExpression: Constants.regularExpressions.numerical

            onTextChanged: asset.decimals = parseInt(text)
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
            },
            StatusValidator {
                id: extraValidatorItem
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

    component CustomNetworkFilterRowComponent: RowLayout {
        id: networkComponent

        property string label
        property string description

        function setChain(chainId) { netFilter.setChain(chainId) }

        Layout.fillWidth: true
        Layout.topMargin: Style.current.padding
        spacing: 32

        CustomLabelDescriptionComponent {
            label: networkComponent.label
            description: networkComponent.description
        }

        NetworkFilter {
            id: netFilter

            Layout.preferredWidth: 160

            allNetworks: root.allNetworks
            layer1Networks: root.layer1Networks
            layer2Networks: root.layer2Networks
            testNetworks: root.testNetworks
            enabledNetworks: root.enabledNetworks

            multiSelection: false

            onToggleNetwork: (network) =>
                             {
                                 if(root.isAssetView) {
                                     asset.chainId = network.chainId
                                     asset.chainName = network.chainName
                                     asset.chainIcon = network.iconUrl
                                 } else {
                                     collectible.chainId = network.chainId
                                     collectible.chainName = network.chainName
                                     collectible.chainIcon = network.iconUrl
                                 }
                             }
        }
    }
}
