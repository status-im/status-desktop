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

    property var store

    property var itemKey
    property real tokenAmount: 0
    property string tokenName: d.defaultTokenNameText
    property url tokenImage: ""
    property real collectibleAmount: 1
    property string collectibleName: d.defaultCollectibleNameText
    property url collectibleImage: ""
    property int operator: SQ.Utils.Operators.None
    property bool withOperatorSelector: true

    signal addItem(var itemKey, string itemText, url itemImage, int operator)

    function reset() {
        d.currentTabIndex = 0
        root.itemKey = undefined
        root.tokenAmount = 0
        root.tokenName = d.defaultTokenNameText
        root.tokenImage = ""
        root.collectibleAmount = 1
        root.collectibleName = d.defaultCollectibleNameText
        root.collectibleImage = ""
        root.operator = SQ.Utils.Operators.None
    }

    QtObject {
        id: d

        // Internal management properties:
        readonly property bool tokensReady: root.tokenAmount > 0 && root.tokenName !== d.defaultTokenNameText
        readonly property bool collectiblesReady: root.collectibleAmount > 0 && root.collectibleName !== d.defaultCollectibleNameText
        readonly property string tokensState: "TOKENS"
        readonly property string collectiblesState: "COLLECTIBLES"
        readonly property string ensState: "ENS"
        property bool isTokensLayout: true
        property int currentTabIndex: 0

        // By design values:
        readonly property int initialHeight: 232
        readonly property int mainHeight: 256
        readonly property int mainExtendedHeight: 276
        readonly property int operatorsHeight: 96
        readonly property int extendedHeight: 417
        readonly property int defaultWidth: 289
        readonly property int operatorsWidth: 159

        property string defaultTokenNameText: qsTr("Choose token")
        property string defaultCollectibleNameText: qsTr("Choose collectible")

        function selectInitState() {
            if(root.withOperatorSelector)
                loader.sourceComponent = operatorsSelectorView
            else
                loader.sourceComponent = tabsView
        }
    }

    implicitWidth: d.defaultWidth
    implicitHeight: loader.implicitHeight

    contentItem: Loader {
        id: loader
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
        height: (item != null && typeof(item) !== 'undefined') ? item.implicitHeight : 0
        sourceComponent: root.withOperatorSelector ? operatorsSelectorView : tabsView
        onSourceComponentChanged: {
            if(sourceComponent == operatorsSelectorView) {
                root.width = d.operatorsWidth
            }
            else {
                root.width = d.defaultWidth
            }
        }
    }

    onOpened: d.selectInitState()
    onClosed: root.reset()
    onWithOperatorSelectorChanged: d.selectInitState()

    Component {
        id: operatorsSelectorView
        ColumnLayout {            
            StatusPickerButton {
                Layout.margins: 8
                Layout.bottomMargin: 0
                Layout.preferredWidth: 143 // by design
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
                Layout.margins: 8
                Layout.topMargin: 0
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
        id: tabsView

        ColumnLayout {
            spacing: 0
            state: d.currentTabIndex === 0 ? d.tokensState : (d.currentTabIndex === 1 ? d.collectiblesState : d.ensState)
            states: [
                State {
                    name: d.tokensState
                    PropertyChanges {target: tabsLoader; sourceComponent: tokensCollectiblesLayout}
                    PropertyChanges {target: d; isTokensLayout: true}
                },
                State {
                    name: d.collectiblesState
                    PropertyChanges {target: tabsLoader; sourceComponent: tokensCollectiblesLayout}
                    PropertyChanges {target: d; isTokensLayout: false}
                },
                State {
                    name: d.ensState
                    PropertyChanges {target: tabsLoader; sourceComponent: ensLayout}
                }
            ]
            StatusIconTextButton {
                visible: root.withOperatorSelector
                Layout.leftMargin: 16
                Layout.topMargin: 12
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
                Layout.margins: 8
                Layout.topMargin: root.withOperatorSelector ? 12 : 16
                Layout.preferredHeight: 36 // by design
                currentIndex: d.currentTabIndex
                onCurrentIndexChanged: d.currentTabIndex = currentIndex
                StatusSwitchTabButton {
                    text: qsTr("Token")
                    fontPixelSize: 13
                }
                StatusSwitchTabButton {
                    text: qsTr("Collectible")
                    fontPixelSize: 13
                }
                StatusSwitchTabButton {
                    text: qsTr("ENS")
                    fontPixelSize: 13
                    enabled: false // TODO
                }
            }
            Loader {
                id: tabsLoader
                Layout.fillWidth: true
                Layout.margins: 8
            }
        }
    }

    Component {
        id: tokensCollectiblesLayout

        ColumnLayout {
            spacing: 0
            StatusPickerButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                bgColor: Theme.palette.baseColor5
                contentColor: Theme.palette.directColor1
                text: d.isTokensLayout ? root.tokenName : root.collectibleName
                font.pixelSize: 13
                image.source: d.isTokensLayout ? root.tokenImage : root.collectibleImage
                onClicked: loader.sourceComponent = extendedView
            }

            RowLayout {
                visible: !d.isTokensLayout
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 16
                Layout.rightMargin: 6
                Layout.topMargin: 8
                StatusBaseText {
                    Layout.fillWidth: true
                    text: qsTr("Specific amount")
                    font.pixelSize: 13
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    clip: true
                }
                StatusSwitch { id: specificAmountSwitch }
            }

            StatusInput {
                Layout.fillWidth: true
                Layout.topMargin: 8
                visible: d.isTokensLayout ? true : specificAmountSwitch.checked
                minimumHeight: 36
                maximumHeight: 36
                topPadding: 0
                bottomPadding: 0
                text: d.isTokensLayout ? (root.tokenAmount === 0 ? "" : root.tokenAmount.toString()) :
                                         (root.collectibleAmount === 0 ? "" : root.collectibleAmount.toString())
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
                onTextChanged: {
                    if(d.isTokensLayout)
                        root.tokenAmount = Number(text)
                    else
                        root.collectibleAmount = Number(text)
                }
            }

            StatusButton {
                enabled: d.isTokensLayout ? d.tokensReady : d.collectiblesReady
                text: qsTr("Add")
                height: 44
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.topMargin: 32
                onClicked: {
                    if(d.isTokensLayout)
                        root.addItem(root.itemKey, root.tokenAmount.toString() + " " + root.tokenName, root.tokenImage, root.operator)
                    else
                        root.addItem(root.itemKey, root.collectibleAmount.toString() + " " + root.collectibleName, root.collectibleImage, root.operator)
                }
            }
        }
    }

    // TODO
    Component {
        id: ensLayout
        Item {}
    } 

    Component {
        id: extendedView

        ExtendedDropdownContent {
            store: root.store
            type: d.isTokensLayout ? ExtendedDropdownContent.Type.Tokens : ExtendedDropdownContent.Type.Collectibles
            onGoBack: loader.sourceComponent = tabsView
            onItemClicked: {
                // Go back
                loader.sourceComponent = tabsView

                if(d.isTokensLayout) {
                    // Update new token item info
                    root.tokenName = name
                    root.tokenImage = iconSource
                }
                else {
                    // Update new collectible item info
                    root.collectibleName = name
                    root.collectibleImage = iconSource
                }
                root.itemKey = key
            }
        }
    }    
}
