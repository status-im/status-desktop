import QtQuick 2.13
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Core.Utils 0.1 as SQ

import utils 1.0

StatusDropdown {
    id: root

    property string tokenAmountValue: ""
    property string tokenName: d.defaultTokenNameText
    property url tokenImage: ""
    property int operator: SQ.Utils.Operators.None
    property bool withOperatorSelector: true

    signal addToken(string tokenText, url tokenImage, int operator)

    function reset() {
        root.tokenAmountValue = ""
        root.tokenName = d.defaultTokenNameText
        root.tokenImage = ""
        root.operator = SQ.Utils.Operators.None

        d.selectInitState()
    }

    QtObject {
        id: d

        readonly property bool ready: root.tokenAmountValue > 0 && root.tokenName !== d.defaultTokenNameText

        // By design values:
        readonly property int initialHeight: 232
        readonly property int mainHeight: 256
        readonly property int operatorsHeight: 96
        readonly property int extendedHeight: 417
        readonly property int defaultWidth: 289
        readonly property int operatorsWidth: 159

        property string defaultTokenNameText: qsTr("Choose token")

        function selectInitState() {
            if(root.withOperatorSelector)
                loader.sourceComponent = operatorsSelectorView
            else
                loader.sourceComponent = tabsView
        }
    }

    width: d.defaultWidth
    height: d.initialHeight

    contentItem: Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: root.withOperatorSelector ? operatorsSelectorView : tabsView

        onSourceComponentChanged: {
            if(sourceComponent == tokensExtendedView) {
                root.height = Math.min(item.contentHeight + item.anchors.topMargin + item.anchors.bottomMargin, d.extendedHeight)
                root.width = d.defaultWidth
            }
            else if(sourceComponent == operatorsSelectorView) {
                root.height = d.operatorsHeight
                root.width = d.operatorsWidth
            }
            else if(sourceComponent == tabsView && root.withOperatorSelector)  {
                root.height = d.mainHeight
                root.width = d.defaultWidth
            }
            else if(sourceComponent == tabsView && !root.withOperatorSelector)  {
                root.height = d.initialHeight
                root.width = d.defaultWidth
            }
        }
    }

    onClosed: root.reset()
    onWithOperatorSelectorChanged: { d.selectInitState() }

    Component {
        id: tabsView

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            anchors.topMargin: 16
            spacing: 8
            StatusIconTextButton {
                visible: root.withOperatorSelector
                Layout.leftMargin: 8
                spacing: 0
                statusIcon: "next"
                icon.width: 12
                icon.height: 12
                iconRotation: 180
                text: qsTr("Back")
                onClicked: loader.sourceComponent = operatorsSelectorView
            }
            StatusSwitchTabBar {
                id: tabBar
                Layout.preferredWidth: 273 // by design
                Layout.preferredHeight: 36 // by design
                StatusSwitchTabButton {
                    text: qsTr("Token")
                    fontPixelSize: 13
                }
                StatusSwitchTabButton {
                    text: qsTr("Collectibles")
                    fontPixelSize: 13
                    enabled: false // TODO
                }
                StatusSwitchTabButton {
                    text: qsTr("ENS")
                    fontPixelSize: 13
                    enabled: false // TODO
                }
            }
            StackLayout {
                Layout.fillWidth: true
                currentIndex: tabBar.currentIndex
                // Tokens layout definition:
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    StatusPickerButton {
                        Layout.fillWidth: true
                        Layout.topMargin: 8
                        Layout.preferredHeight: 36
                        bgColor: Theme.palette.baseColor5
                        contentColor: Theme.palette.directColor1
                        text: root.tokenName
                        font.pixelSize: 13
                        image.source: root.tokenImage
                        onClicked: loader.sourceComponent = tokensExtendedView
                    }

                    // TODO: Update preferredHeight according to design once `StatusInput` behaves correclty with different heights.
                    StatusInput {
                        Layout.fillWidth: true
                        //Layout.preferredHeight: 36
                        text: root.tokenAmountValue
                        font.pixelSize: 13
                        rightPadding: amountText.implicitWidth + amountText.anchors.rightMargin + leftPadding
                        input.placeholderText: "0"
                        validationMode: StatusInput.ValidationMode.IgnoreInvalidInput
                        validators: StatusFloatValidator {  bottom: 0 }

                        StatusBaseText {
                            id: amountText
                            anchors.right: parent.right
                            anchors.rightMargin: 13
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Amount")
                            color: Theme.palette.baseColor1
                            font.pixelSize: 13
                        }
                        onTextChanged: root.tokenAmountValue = text
                    }
                    // Just a filler
                    Item { Layout.fillHeight: true}
                    // TODO: Needed `StatusButton` redesign that allows to fill the width.
                    StatusButton {
                        enabled: d.ready
                        text: qsTr("Add")
                        height: 44
                        Layout.alignment: Qt.AlignHCenter
                        //Layout.fillWidth: true
                        onClicked: { root.addToken(root.tokenAmountValue + " " + root.tokenName, root.tokenImage, root.operator) }
                    }
                } // End of Tokens Layout definition

                // TODO
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // TODO
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }

    Component {
        id: operatorsSelectorView
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            StatusPickerButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                horizontalPadding: 12
                spacing: 10
                bgColor: Theme.palette.primaryColor3
                contentColor: Theme.palette.primaryColor1
                image.source: Style.svg("add")
                text: qsTr("And...")
                image.height: 12
                image.width: 12
                font.pixelSize: 13
                onClicked: {
                    root.operator = SQ.Utils.Operators.And
                    loader.sourceComponent = tabsView
                }
            }
            StatusPickerButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                horizontalPadding: 12
                spacing: 10
                bgColor: Theme.palette.primaryColor3
                contentColor: Theme.palette.primaryColor1
                image.source: Style.svg("condition-Or")
                image.height: 12
                image.width: 12
                text: qsTr("Or...")
                font.pixelSize: 13
                onClicked: {
                    root.operator = SQ.Utils.Operators.Or
                    loader.sourceComponent = tabsView
                }
            }
        }
    }

    Component {
        id: tokensExtendedView

        // TODO: It probabily will be a reusable component for collectibles and channels
        TokensListDropdownContent {
            anchors.fill: parent
            anchors.topMargin: 8
            anchors.bottomMargin: 8
            headerModel: ListModel {
                ListElement { index: 0; icon: "next"; iconSize: 12; description: qsTr("Back"); rotation: 180; spacing: 0 }
                ListElement { index: 1; icon: "add"; iconSize: 16; description: qsTr("Mint token"); rotation: 0; spacing: 8 }
                ListElement { index: 2; icon: "invite-users"; iconSize: 16; description: qsTr("Import existing token"); rotation: 180; spacing: 8 }
            }
            // TODO: Replace to real data, now dummy model
            model: ListModel {
                ListElement {imageSource: "qrc:imports/assets/png/tokens/SOCKS.png"; name: "Unisocks"; shortName: "SOCKS"; selected: false; category: "Community tokens"}
                ListElement {imageSource: "qrc:imports/assets/png/tokens/ZRX.png"; name: "Ox"; shortName: "ZRX"; selected: false; category: "Listed tokens"}
                ListElement {imageSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png"; name: "1inch"; shortName: "ZRX"; selected: false; category: "Listed tokens"}
                ListElement {imageSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png"; name: "Aave"; shortName: "AAVE"; selected: false; category: "Listed tokens"}
                ListElement {imageSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png"; name: "Amp"; shortName: "AMP"; selected: false; category: "Listed tokens"}
            }
            onHeaderItemClicked: {
                if(index === 0) loader.sourceComponent = tabsView // Go back
                // TODO:
                else if(index === 1) console.log("TODO: Mint token")
                else if(index === 2) console.log("TODO: Import existing token")
            }
            onItemClicked: {
                // Go back
                loader.sourceComponent = tabsView

                // Update new token info
                root.tokenName = shortName
                root.tokenImage = imageSource                
            }
        }
    }
}
