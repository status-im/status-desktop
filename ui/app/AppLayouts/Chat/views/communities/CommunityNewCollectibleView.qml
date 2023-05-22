import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import utils 1.0


import AppLayouts.Wallet.controls 1.0
import shared.panels 1.0
import shared.popups 1.0

StatusScrollView {
    id: root

    property int viewWidth: 560 // by design
    property bool isAssetView: false

    // Token properties
    readonly property alias name: nameInput.text
    readonly property alias symbol: symbolInput.text
    readonly property alias description: descriptionInput.text
    readonly property alias infiniteSupply: unlimitedSupplyChecker.checked
    readonly property int supplyAmount: supplyInput.text ? parseInt(supplyInput.text) : 0
    property alias artworkSource: dropAreaItem.artworkSource
    property alias artworkCropRect: dropAreaItem.artworkCropRect
    property int chainId
    property string chainName
    property string chainIcon
    property var tokensModel

    // Collectible properties
    readonly property alias notTransferable: transferableChecker.checked
    readonly property alias selfDestruct: selfDestructChecker.checked

    // Asset properties
    readonly property int assetDecimals: assetDecimalsInput.text ? parseInt(assetDecimalsInput.text) : 0

    // Network related properties:
    property var layer1Networks
    property var layer2Networks
    property var testNetworks
    property var enabledNetworks
    property var allNetworks

    // Account related properties:
    // Account expected roles: address, name, color, emoji
    property var accounts
    readonly property string accountAddress: accountsComboBox.address
    readonly property string accountName: accountsComboBox.control.displayText

    signal chooseArtWork
    signal previewClicked

    QtObject {
        id: d

        readonly property bool isFullyFilled: root.artworkSource.toString().length > 0
                                              && nameInput.valid
                                              && descriptionInput.valid
                                              && symbolInput.valid
                                              && (root.infiniteSupply || (!root.infiniteSupply && root.supplyAmount > 0))
                                              && (!root.isAssetView  || (root.isAssetView&& assetDecimalsInput.valid))

        readonly property int imageSelectorRectWidth: root.isAssetView ? 128 : 290
    }

    contentWidth: mainLayout.width
    contentHeight: mainLayout.height
    padding: 0

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
            editorAnchorLeft: !root.isAssetView
            editorRoundedImage: root.isAssetView
            uploadTextLabel.uploadText: root.isAssetView ? qsTr("Upload") : qsTr("Drag and Drop or Upload Artwork")
            uploadTextLabel.additionalText: qsTr("Images only")
            uploadTextLabel.showAdditionalInfo: !root.isAssetView
            editorTitle: root.isAssetView ? qsTr("Asset icon") : qsTr("Collectible artwork")
            acceptButtonText: root.isAssetView ? qsTr("Upload asset icon") : qsTr("Upload collectible artwork")
        }

        CustomStatusInput {
            id: nameInput

            label: qsTr("Name")
            charLimit: 15
            placeholderText: qsTr("Name")
            minLengthValidator.errorMessage: qsTr("Please name your token name (use A-Z and 0-9, hyphens and underscores only)")
            regexValidator.errorMessage: qsTr("Your token name contains invalid characters (use A-Z and 0-9, hyphens and underscores only)")
            extraValidator.validate: function (value) { return !SQUtils.ModelUtils.contains(root.tokensModel, "name", nameInput.text) }
            extraValidator.errorMessage: qsTr("You have used this token name before")
        }

        CustomStatusInput {
            id: descriptionInput

            label: qsTr("Description")
            charLimit: 280
            placeholderText: root.isAssetView ? qsTr("Describe your asset") : qsTr("Describe your collectible")
            input.multiline: true
            input.verticalAlignment: Qt.AlignTop
            input.placeholder.verticalAlignment: Qt.AlignTop
            minimumHeight: 108
            maximumHeight: minimumHeight
            minLengthValidator.errorMessage: qsTr("Please enter a token description")
            regexValidator.regularExpression: Constants.regularExpressions.asciiPrintable
            regexValidator.errorMessage: qsTr("Only A-Z, 0-9 and standard punctuation allowed")
        }

        CustomStatusInput {
            id: symbolInput

            label: qsTr("Symbol")
            charLimit: 6
            placeholderText: qsTr("e.g. DOODLE")
            minLengthValidator.errorMessage: qsTr("Please enter your token symbol (use A-Z only)")
            regexValidator.errorMessage: qsTr("Your token symbol contains invalid characters (use A-Z only)")
            regexValidator.regularExpression: Constants.regularExpressions.capitalOnly
            extraValidator.validate: function (value) { return !SQUtils.ModelUtils.contains(root.tokensModel, "symbol", symbolInput.text) }
            extraValidator.errorMessage: qsTr("You have used this token symbol before")
        }

        CustomLabelDescriptionComponent {
            Layout.topMargin: Style.current.padding
            label: qsTr("Select account")
            description: qsTr("Account will be required for all subsequent interactions with this token. Remember everybody in your community will be able to see this address.")
        }

        StatusEmojiAndColorComboBox {
            id: accountsComboBox

            readonly property string address: SQUtils.ModelUtils.get(root.accounts, currentIndex, "address")

            Layout.fillWidth: true
            model: root.accounts
            type: StatusComboBox.Type.Secondary
            size: StatusComboBox.Size.Small
            implicitHeight: 44
            defaultAssetName: "filled-account"
        }

        CustomNetworkFilterRowComponent {
            label: qsTr("Select network")
            description: qsTr("The network on which this token will be minted")
        }

        CustomSwitchRowComponent {
            id: unlimitedSupplyChecker

            label: qsTr("Unlimited supply")
            description: qsTr("Enable to allow the minting of additional tokens in the future. Disable to specify a finite supply")
            checked: true

            onCheckedChanged: if(!checked) supplyInput.forceActiveFocus()
        }

        CustomStatusInput {
            id: supplyInput

            visible: !unlimitedSupplyChecker.checked
            label: qsTr("Total finite supply")
            placeholderText: qsTr("e.g. 300")
            minLengthValidator.errorMessage: qsTr("Please enter a total finite supply")
            regexValidator.errorMessage: qsTr("Your total finite supply contains invalid characters (use 0-9 only)")
            regexValidator.regularExpression: Constants.regularExpressions.numerical
            extraValidator.validate: function (value) { return  parseInt(value) > 0 && parseInt(value) <= 999999999 }
            extraValidator.errorMessage: qsTr("Enter a number between 0 and 999,999,999")
        }

        CustomSwitchRowComponent {
            id: transferableChecker

            visible: !root.isAssetView
            label: checked ? qsTr("Not transferable (Soulbound)") : qsTr("Transferable")
            description: qsTr("If enabled, the token is locked to the first address it is sent to and can never be transferred to another address. Useful for tokens that represent Admin permissions")
            checked: true
        }

        CustomSwitchRowComponent {
            id: selfDestructChecker

            visible: !root.isAssetView
            label: qsTr("Remotely destructible")
            description: qsTr("Enable to allow you to destroy tokens remotely. Useful for revoking permissions from individuals")
            checked: true
        }

        CustomStatusInput {
            id: assetDecimalsInput

            visible: root.isAssetView
            label: qsTr("Decimals")
            charLimit: 2
            charLimitLabel: qsTr("Max 10")
            placeholderText: "2"
            text: "2" // Default value
            validationMode: StatusInput.ValidationMode.Always
            minLengthValidator.errorMessage: qsTr("Please enter how many decimals your token should have")
            regexValidator.errorMessage: qsTr("Your decimal amount contains invalid characters (use 0-9 only)")
            regexValidator.regularExpression: Constants.regularExpressions.numerical
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
                regularExpression: Constants.regularExpressions.alphanumerical
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

        Layout.fillWidth: true
        Layout.topMargin: Style.current.padding
        spacing: 32

        CustomLabelDescriptionComponent {
            label: networkComponent.label
            description: networkComponent.description
        }

        NetworkFilter {
            Layout.preferredWidth: 160

            allNetworks: root.allNetworks
            layer1Networks: root.layer1Networks
            layer2Networks: root.layer2Networks
            testNetworks: root.testNetworks
            enabledNetworks: root.enabledNetworks

            multiSelection: false

            onToggleNetwork: (network) =>
                             {
                                 root.chainId = network.chainId
                                 root.chainName = network.chainName
                                 root.chainIcon = network.iconUrl
                             }
        }
    }
}
