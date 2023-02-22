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

    property var store
    property var tokensModel // TEMPORARY
    property int viewWidth: 560 // by design

    signal chooseArtWork
    signal previewClicked

    // TEMPORAL
    signal mintCollectible(url artworkSource,
                           string name,
                           string symbol,
                           string description,
                           int supply,
                           bool infiniteSupply,
                           bool transferable,
                           bool selfDestruct,
                           int chainId)

    QtObject {
        id: d

        readonly property bool isFullyFilled: d.artworkSource.toString().length > 0
                                              && !!nameInput.text
                                              && !!symbolInput.text
                                              && !!descriptionInput.text
                                              && (unlimitedSupplyItem.checked || (!unlimitedSupplyItem.checked && supplyInput.text.length > 0))


        readonly property int imageSelectorRectWidth: 280

        property url artworkSource
        property int networkSelected
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

            onFileSelected: d.artworkSource = file
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
                store: root.store
                isChainVisible: false
                multiSelection: false

                onSingleNetworkSelected: d.networkSelected = chainId
            }
        }

        CustomRowComponent {
            label: qsTr("Select network")
            description: qsTr("The network on which this token will be minted")
            checked: true
            isSwitchCase: false
        }

        CustomRowComponent {
            id: unlimitedSupplyItem

            label: qsTr("Unlimited supply")
            description: qsTr("Enable to allow the minting of additional collectibles in the future. Disable to specify a finite supply")
            checked: true
        }

        StatusInput {
            id: supplyInput

            visible: !unlimitedSupplyItem.checked
            label: qsTr("Total finite supply")
            placeholderText: "1"
            validators: StatusIntValidator{bottom: 1; top: 999999999;}
        }

        CustomRowComponent {
            id: transferibleChecker

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
            text: qsTr("Preview")
            enabled: d.isFullyFilled

            onClicked: {
                root.previewClicked()

                // TEMPORAL
                root.mintCollectible(d.artworkSource,
                                     nameInput.text,
                                     symbolInput.text,
                                     descriptionInput.text,
                                     parseInt(supplyInput.text),
                                     unlimitedSupplyItem.checked,
                                     transferibleChecker.checked,
                                     selfDestructChecker.checked,
                                     d.networkSelected)
            }
        }

        // TEMPORAL:
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: backendChecker.implicitHeight
            color: "darkgrey"
            radius: 8

            ColumnLayout {
                id: backendChecker

                StatusBaseText {
                    Layout.margins: 16
                    text: "Backend checker - Minted collectibles"
                    font.bold: true
                }

                ListView {
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 100
                    model: root.tokensModel
                    delegate: Text {
                        text: "name: " + name + ", descr: " + description + ", supply: " + supply + ", status: " + deployState
                    }
                }
            }
        }
    }
}
