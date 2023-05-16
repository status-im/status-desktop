import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0

import AppLayouts.Wallet.controls 1.0
import shared.panels 1.0
import shared.popups 1.0

StatusScrollView {
    id: root

    property int viewWidth: 560 // by design

    // Collectible properties
    readonly property alias name: nameInput.text
    readonly property alias symbol: symbolInput.text
    readonly property alias description: descriptionInput.text
    readonly property alias infiniteSupply: unlimitedSupplyChecker.checked
    readonly property alias notTransferable: transferableChecker.checked
    readonly property alias selfDestruct: selfDestructChecker.checked
    readonly property int supplyAmount: supplyInput.text ? parseInt(supplyInput.text) : 0
    property alias artworkSource: dropAreaItem.artworkSource
    property alias artworkCropRect: dropAreaItem.artworkCropRect
    property int chainId
    property string chainName
    property string chainIcon

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

        property bool isAssetView: (optionsTab.currentIndex === 1)
        readonly property bool isFullyFilled: root.artworkSource.toString().length > 0
                                              && !!root.name
                                              && !!root.symbol
                                              && !!root.description
                                              && (root.infiniteSupply || (!root.infiniteSupply && root.supplyAmount > 0))


        readonly property int imageSelectorRectWidth: d.isAssetView ? 128 : 290
    }

    contentWidth: mainLayout.width
    contentHeight: mainLayout.height
    padding: 0

    ColumnLayout {
        id: mainLayout

        width: root.viewWidth
        spacing: Style.current.padding

        StatusTabBar {
            //TODO replace with tab bar from design when this
            //https://github.com/status-im/status-desktop/issues/10623 is done
            id: optionsTab
            StatusTabButton {
                id: assetBtn
                width: implicitWidth
                text: qsTr("Collectibles")
            }
            StatusTabButton {
                id: collectiblesBtn
                width: implicitWidth
                text: qsTr("Assets")
            }
        }

        StatusBaseText {
            elide: Text.ElideRight
            font.pixelSize: Theme.primaryTextFontSize
            text: qsTr("Artwork")
        }

        DropAndEditImagePanel {
            id: dropAreaItem
            Layout.fillWidth: true
            Layout.preferredHeight: d.imageSelectorRectWidth
            editorAnchorLeft: !d.isAssetView
            editorRoundedImage: d.isAssetView
            uploadTextLabel.uploadText: d.isAssetView ? qsTr("Upload") : qsTr("Drag and Drop or Upload Artwork")
            uploadTextLabel.additionalText: qsTr("Images only")
            uploadTextLabel.showAdditionalInfo: !d.isAssetView
            editorTitle: qsTr("Collectible artwork")
            acceptButtonText: qsTr("Upload collectible artwork")
        }

        CustomStatusInput {
            id: nameInput

            label: qsTr("Name")
            charLimit: 15
            placeholderText: qsTr("Name")
            errorText: qsTr("Collectible name")
        }

        CustomStatusInput {
            id: descriptionInput

            label: qsTr("Description")
            charLimit: 280
            placeholderText: qsTr("Describe your collectible")
            input.multiline: true
            input.verticalAlignment: Qt.AlignTop
            input.placeholder.verticalAlignment: Qt.AlignTop
            minimumHeight: 108
            maximumHeight: minimumHeight
            errorText: qsTr("Collectible description")
        }

        CustomStatusInput {
            id: symbolInput

            label: qsTr("Symbol")
            charLimit: 6
            placeholderText: qsTr("e.g. DOODLE")
            errorText: qsTr("Collectible symbol")
            validator.regularExpression: Constants.regularExpressions.asciiPrintable
        }

        CustomLabelDescriptionComponent {
            Layout.topMargin: Style.current.padding
            label: qsTr("Select account")
            description: qsTr("Account will be required for all subsequent interactions with this token. Remember everybody in your community will be able to see this address.")
        }

        StatusEmojiAndColorComboBox {
            id: accountsComboBox

            readonly property string address: ModelUtils.get(root.accounts, currentIndex, "address")

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

        StatusInput {
            id: supplyInput

            visible: !unlimitedSupplyChecker.checked
            label: qsTr("Total finite supply")
            placeholderText: qsTr("e.g. 300")
            validators: StatusIntValidator{bottom: 1; top: 999999999;}
        }

        CustomSwitchRowComponent {
            id: transferableChecker
            visible: (optionsTab.currentIndex === 0)
            label: checked ? qsTr("Not transferable (Soulbound)") : qsTr("Transferable")
            description: qsTr("If enabled, the token is locked to the first address it is sent to and can never be transferred to another address. Useful for tokens that represent Admin permissions")
            checked: true
        }

        CustomSwitchRowComponent {
            id: selfDestructChecker
            visible: (optionsTab.currentIndex === 0)
            label: qsTr("Remotely destructible")
            description: qsTr("Enable to allow you to destroy tokens remotely. Useful for revoking permissions from individuals")
            checked: true
        }

        CustomStatusInput {
            visible: (optionsTab.currentIndex === 1)
            label: qsTr("Decimals")
            secondaryLabel: "Max 10"
            placeholderText: qsTr("2")
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

        property string errorText
        property alias validator: regexValidator

        Layout.fillWidth: true
        validators: [
            StatusMinLengthValidator {
                minLength: 1
                errorMessage: Utils.getErrorMessage(customInput.errors,
                                                    customInput.errorText)
            },
            StatusRegularExpressionValidator {
                id: regexValidator
                regularExpression: Constants.regularExpressions.ascii
                errorMessage: Constants.errorMessages.asciiRegExp
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
