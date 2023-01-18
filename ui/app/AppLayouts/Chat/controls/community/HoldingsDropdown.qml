import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Chat.helpers 1.0

StatusDropdown {
    id: root

    property var store

    property string assetKey: ""
    property real assetAmount: 0

    property string collectibleKey: ""
    property real collectibleAmount: 1

    property string ensDomainName: ""

    signal addAsset(string key, real amount)
    signal addCollectible(string key, real amount)
    signal addEns(string domain)

    signal updateAsset(string key, real amount)
    signal updateCollectible(string key, real amount)
    signal updateEns(string domain)

    signal removeClicked

    enum FlowType {
        Selected, List_Deep1, List_Deep2
    }

    function openUpdateFlow() {
        d.currentHoldingMode = HoldingTypes.Mode.Update
        if(d.currentHoldingType !== HoldingTypes.Type.Ens) {
            if(statesStack.size === 0)
                statesStack.push(HoldingsDropdown.FlowType.List_Deep1)

            statesStack.push(HoldingsDropdown.FlowType.Selected)
        }
        open()
    }

    function setActiveTab(holdingType) {
        d.currentHoldingType = holdingType
    }

    function reset() {
        d.currentHoldingType = HoldingTypes.Type.Asset
        d.currentHoldingMode = HoldingTypes.Mode.Add

        d.assetAmountText = ""
        d.collectibleAmountText = ""
        root.assetKey = ""
        root.collectibleKey = ""
        root.assetAmount = 0
        root.collectibleAmount = 1
        root.ensDomainName = ""

        d.setInitialFlow()
    }

    QtObject {
        id: d

        // Internal management properties and signals:
        readonly property var holdingTypes: [
            HoldingTypes.Type.Asset, HoldingTypes.Type.Collectible, HoldingTypes.Type.Ens
        ]
        readonly property bool assetsReady: root.assetAmount > 0 && root.assetKey
        readonly property bool collectiblesReady: root.collectibleAmount > 0 && root.collectibleKey
        readonly property bool ensReady: d.ensDomainNameValid

        property int extendedDropdownType: ExtendedDropdownContent.Type.Assets
        property int currentHoldingType: HoldingTypes.Type.Asset
        property int currentHoldingMode: HoldingTypes.Mode.Add
        property bool extendedDeepNavigation: false
        property var currentSubItems
        property string currentItemKey: ""

        property string assetAmountText: ""
        property string collectibleAmountText: "1"
        property bool ensDomainNameValid: false

        // By design values:
        readonly property int padding: 8
        readonly property int defaultWidth: 289
        readonly property int extendedContentHeight: 380
        readonly property int tabBarHeigh: 36
        readonly property int tabBarTextSize: 13
        readonly property int backButtonWidth: 56
        readonly property int backButtonHeight: 24
        readonly property int backButtonToContentSpace: 8

        function setInitialFlow() {
            statesStack.clear()
            if(d.currentHoldingType !== HoldingTypes.Type.Ens)
                statesStack.push(HoldingsDropdown.FlowType.List_Deep1)
            else
                statesStack.push(HoldingsDropdown.FlowType.Selected)
        }
    }

    QtObject {
        id: statesStack

        property alias currentState: content.state
        property int size: 0
        property var states: []

        function push(state) {
            states.push(state)
            currentState = state
            size++
        }

        function pop() {
            states.pop()
            currentState = states.length ? states[states.length - 1] : ""
            size--
        }

        function clear() {
            currentState = ""
            size = 0
            states = []
        }
    }

    width: d.defaultWidth
    padding: d.padding
    margins: 0  // force keeping within the bounds of the enclosing window
    contentItem: ColumnLayout {
        id: content

        spacing: d.backButtonToContentSpace

        StatusIconTextButton {
            id: backButton

            Layout.preferredWidth: d.backButtonWidth
            Layout.preferredHeight: d.backButtonHeight
            visible: statesStack.size > 1
            spacing: 0
            leftPadding: 4
            statusIcon: "next"
            icon.width: 12
            icon.height: 12
            iconRotation: 180
            text: qsTr("Back")
        }

        StatusSwitchTabBar {
            id: tabBar

            visible: !backButton.visible
            Layout.preferredHeight: d.tabBarHeigh
            Layout.fillWidth: true
            currentIndex: d.holdingTypes.indexOf(d.currentHoldingType)
            state: d.currentHoldingType
            states: [
                State {
                    name: HoldingTypes.Type.Asset
                    PropertyChanges {target: loader; sourceComponent: listLayout}
                    PropertyChanges {target: root; height: d.extendedContentHeight}
                    PropertyChanges {target: d; extendedDropdownType: ExtendedDropdownContent.Type.Assets}
                },
                State {
                    name: HoldingTypes.Type.Collectible
                    PropertyChanges {target: loader; sourceComponent: listLayout}
                    PropertyChanges {target: root; height: d.extendedContentHeight}
                    PropertyChanges {target: d; extendedDropdownType: ExtendedDropdownContent.Type.Collectibles}
                },
                State {
                    name: HoldingTypes.Type.Ens
                    PropertyChanges {target: loader; sourceComponent: ensLayout}
                    PropertyChanges {target: root; height: undefined} // use implicit height
                }
            ]

            onCurrentIndexChanged: {
                d.currentHoldingType = d.holdingTypes[currentIndex]
                d.setInitialFlow()
            }

            Repeater {
                id: tabLabelsRepeater
                model: [qsTr("Asset"), qsTr("Collectible"), qsTr("ENS")]

                StatusSwitchTabButton {
                    text: modelData
                    fontPixelSize: d.tabBarTextSize
                }
            }
        }

        Loader {
            id: loader
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        states: [
            State {
                name: HoldingsDropdown.FlowType.Selected
                PropertyChanges {target: loader; sourceComponent: (d.currentHoldingType === HoldingTypes.Type.Asset) ? assetLayout :
                                                                  ((d.currentHoldingType === HoldingTypes.Type.Collectible) ? collectibleLayout : ensLayout) }
                PropertyChanges {target: root; height: undefined} // use implicit height
            },
            State {
                name: HoldingsDropdown.FlowType.List_Deep1
                PropertyChanges {target: loader; sourceComponent: listLayout}
                PropertyChanges {target: root; height: d.extendedContentHeight}
                PropertyChanges {target: d; extendedDeepNavigation: false}                
            },
            State {
                name: HoldingsDropdown.FlowType.List_Deep2
                extend: HoldingsDropdown.FlowType.List_Deep1
                PropertyChanges {target: d; extendedDeepNavigation: true}
            }
        ]
    }

    onClosed: root.reset()

    Component {
        id: listLayout

        ExtendedDropdownContent {
            id: listPanel

            store: root.store
            type: d.extendedDropdownType

            onItemClicked: {
                if(d.extendedDropdownType === ExtendedDropdownContent.Type.Assets)
                    root.assetKey = key
                else
                    root.collectibleKey = key

                statesStack.push(HoldingsDropdown.FlowType.Selected)
            }

            onNavigateDeep: {
                d.currentSubItems = subItems
                d.currentItemKey = key
                statesStack.push(HoldingsDropdown.FlowType.List_Deep2)
            }

            Component.onCompleted: {
                if(d.extendedDeepNavigation)
                    listPanel.goForward(d.currentItemKey,
                                        CommunityPermissionsHelpers.getTokenNameByKey(store.collectiblesModel, d.currentItemKey),
                                        CommunityPermissionsHelpers.getTokenIconByKey(store.collectiblesModel, d.currentItemKey),
                                        d.currentSubItems)
            }

            Connections {
                target: backButton

                function onClicked() {
                    if (listPanel.canGoBack)
                        listPanel.goBack()
                    statesStack.pop()
                }
            }

            Connections {
                target: root

                function onClosed() { listPanel.goBack() }
            }
        }
    }

    Component {
        id: assetLayout

        TokenPanel {
            id: assetPanel

            readonly property real effectiveAmount: amountValid ? amount : 0

            tokenName: CommunityPermissionsHelpers.getTokenNameByKey(store.assetsModel, root.assetKey)
            tokenShortName: CommunityPermissionsHelpers.getTokenShortNameByKey(store.assetsModel, root.assetKey)
            tokenImage: CommunityPermissionsHelpers.getTokenIconByKey(store.assetsModel, root.assetKey)
            amountText: d.assetAmountText
            tokenCategoryText: qsTr("Asset")
            addOrUpdateButtonEnabled: d.assetsReady
            mode: d.currentHoldingMode

            onEffectiveAmountChanged: root.assetAmount = effectiveAmount
            onAmountTextChanged: d.assetAmountText = amountText
            onAddClicked: root.addAsset(root.assetKey, root.assetAmount)
            onUpdateClicked: root.updateAsset(root.assetKey, root.assetAmount)
            onRemoveClicked: root.removeClicked()

            Component.onCompleted: {
                if (d.assetAmountText.length === 0 && root.assetAmount)
                    assetPanel.setAmount(root.assetAmount)
            }

            Connections {
                target: backButton

                function onClicked() { statesStack.pop() }
            }
        }
    }

    Component {
        id: collectibleLayout

        TokenPanel {
            id: collectiblePanel

            readonly property real effectiveAmount: amountValid ? amount : 0

            tokenName: CommunityPermissionsHelpers.getTokenNameByKey(store.collectiblesModel, root.collectibleKey)
            tokenShortName: ""
            tokenImage: CommunityPermissionsHelpers.getTokenIconByKey(store.collectiblesModel, root.collectibleKey)
            amountText: d.collectibleAmountText
            tokenCategoryText: qsTr("Collectible")
            addOrUpdateButtonEnabled: d.collectiblesReady
            allowDecimals: false
            mode: d.currentHoldingMode

            onEffectiveAmountChanged: root.collectibleAmount = effectiveAmount
            onAmountTextChanged: d.collectibleAmountText = amountText
            onAddClicked: root.addCollectible(root.collectibleKey, root.collectibleAmount)
            onUpdateClicked: root.updateCollectible(root.collectibleKey, root.collectibleAmount)
            onRemoveClicked: root.removeClicked()

            Component.onCompleted: {
                    if (d.collectibleAmountText.length === 0 && root.collectibleAmount)
                        collectiblePanel.setAmount(root.collectibleAmount)
            }

            Connections {
                target: backButton

                function onClicked() { statesStack.pop() }
            }
        }
    }

    Component {
        id: ensLayout

        EnsPanel {
            addButtonEnabled: d.ensReady
            domainName: root.ensDomainName
            mode: d.currentHoldingMode

            onDomainNameChanged: root.ensDomainName = domainName
            onDomainNameValidChanged: d.ensDomainNameValid = domainNameValid
            onAddClicked: root.addEns(root.ensDomainName)
            onUpdateClicked: root.updateEns(root.ensDomainName)
            onRemoveClicked: root.removeClicked()
        }
    }
}
