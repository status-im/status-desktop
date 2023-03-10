import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import utils 1.0

import "../../../Wallet/controls"
import shared.panels 1.0

StatusScrollView {
    id: root

    property int viewWidth: 560 // by design

    // Collectible properties
    property alias name: nameInput.text
    property alias symbol: symbolInput.text
    property alias description: descriptionInput.text
    property alias supplyText: supplyInput.text
    property alias infiniteSupply: unlimitedSupplyChecker.checked
    property alias transferable: transferableChecker.checked
    property alias selfDestruct: selfDestructChecker.checked
    property url artworkSource
    property int chainId
    property string chainName
    property string chainIcon

    // Network related properties:
    property var layer1Networks
    property var layer2Networks
    property var testNetworks
    property var enabledNetworks
    property var allNetworks

    signal chooseArtWork
    signal previewClicked

    QtObject {
        id: d

        readonly property bool isFullyFilled: root.artworkSource.toString().length > 0
                                              && !!root.name
                                              && !!root.symbol
                                              && !!root.description
                                              && (root.infiniteSupply || (!root.infiniteSupply && root.supplyText.length > 0))


        readonly property int imageSelectorRectWidth: 280
    }

    contentWidth: mainLayout.width
    contentHeight: mainLayout.height
    padding: 0

    ColumnLayout {
        id: mainLayout

        width: root.viewWidth
        spacing: Style.current.padding

        StatusImageSelector {
            Layout.preferredHeight: d.imageSelectorRectWidth + headerHeight
            Layout.preferredWidth: d.imageSelectorRectWidth + buttonsInsideOffset
            labelText: qsTr("Artwork")
            uploadText: qsTr("Drag and Drop or Upload Artwork")
            additionalText: qsTr("Images only")
            acceptedImageExtensions: Constants.acceptedDragNDropImageExtensions
            file: root.artworkSource

            onFileSelected: root.artworkSource = file
        }

        component CustomStatusInput: StatusInput {
            id: customInput

            property string errorText

            Layout.fillWidth: true
            validators: [
                StatusMinLengthValidator {
                    minLength: 1
                    errorMessage: Utils.getErrorMessage(root.errors,
                                                        customInput.errorText)
                },
                StatusRegularExpressionValidator {
                    regularExpression: Constants.regularExpressions.alphanumericalExpanded
                    errorMessage: Constants.errorMessages.alphanumericalExpandedRegExp
                }
            ]
        }

        CustomStatusInput {
            id: nameInput

            label: qsTr("Name")
            charLimit: 30
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

            label: qsTr("Token symbol")
            charLimit: 5
            placeholderText: qsTr("Letter token abbreviation e.g. ABC")
            errorText: qsTr("Token symbol")
        }

        component CustomRowComponent: RowLayout {
            id: rowComponent

            property string label
            property string description
            property bool checked
            property bool isSwitchCase: true

            Layout.fillWidth: true
            Layout.topMargin: 24
            spacing: rowComponent.isSwitchCase ? 64 : 32

            ColumnLayout {
                Layout.fillWidth: true

                StatusBaseText {
                    text: rowComponent.label
                    color: Theme.palette.directColor1
                    font.pixelSize: Theme.primaryTextFontSize
                }

                StatusBaseText {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: rowComponent.description
                    color: Theme.palette.baseColor1
                    font.pixelSize: Theme.primaryTextFontSize
                    lineHeight: 1.2
                    wrapMode: Text.WordWrap
                }
            }

            StatusSwitch {
                visible: rowComponent.isSwitchCase
                checked: rowComponent.checked
                onToggled: rowComponent.checked = checked
            }

            NetworkFilter {
                visible: !rowComponent.isSwitchCase
                Layout.preferredWidth: 160
                layer1Networks: root.layer1Networks
                layer2Networks: root.layer2Networks
                testNetworks: root.testNetworks
                enabledNetworks: root.testNetworks
                allNetworks: root.allNetworks
                isChainVisible: false
                multiSelection: false

                onSingleNetworkSelected: {
                    root.chainId = chainId
                    root.chainName = chainName
                    root.chainIcon = chainIcon
                }
            }
        }

        CustomRowComponent {
            label: qsTr("Select network")
            description: qsTr("The network on which this token will be minted")
            checked: true
            isSwitchCase: false
        }

        CustomRowComponent {
            id: unlimitedSupplyChecker

            label: qsTr("Unlimited supply")
            description: qsTr("Enable to allow the minting of additional collectibles in the future. Disable to specify a finite supply")
            checked: true
        }

        StatusInput {
            id: supplyInput

            visible: !unlimitedSupplyChecker.checked
            label: qsTr("Total finite supply")
            placeholderText: "1"
            validators: StatusIntValidator{bottom: 1; top: 999999999;}
        }

        CustomRowComponent {
            id: transferableChecker

            label: qsTr("Not transferable (Soulbound)")
            description: qsTr("If enabled, the token is locked to the first address it is sent to and can never be transferred to another address. Useful for tokens that represent Admin permissions")
            checked: true
        }

        CustomRowComponent {
            id: selfDestructChecker

            label: qsTr("Remote self-destruct")
            description: qsTr("Enable to allow you to destroy tokens remotely. Useful for revoking permissions from individuals")
            checked: true
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
}
