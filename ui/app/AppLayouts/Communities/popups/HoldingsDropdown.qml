import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Communities.controls 1.0
import AppLayouts.Communities.helpers 1.0
import utils 1.0

StatusDropdown {
    id: root

    property string communityId
    property var assetsModel
    property var collectiblesModel
    property bool isENSTab: true
    property string noDataText: {
        if(d.currentHoldingType  ===  HoldingTypes.Type.Asset)
            return noDataTextForAssets
        if(d.currentHoldingType === HoldingTypes.Type.Collectible)
            return noDataTextForCollectibles
        return qsTr("No data found")
    }
    property string noDataTextForAssets: qsTr("No assets found")
    property string noDataTextForCollectibles: qsTr("No collectibles found")

    property var usedTokens: []
    property var usedEnsNames: []

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
    signal navigateToMintTokenSettings(bool isAssetType)

    enum FlowType {
        Selected, List_Deep1, List_Deep1_All, List_Deep2
    }

    function openUpdateFlow() {
        d.initialHoldingMode = HoldingTypes.Mode.UpdateOrRemove
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
        d.initialHoldingMode = HoldingTypes.Mode.Add

        root.assetKey = ""
        root.collectibleKey = ""
        root.ensDomainName = ""

        d.setDefaultAmounts()
        d.setInitialFlow()
    }

    QtObject {
        id: d

        // Internal management properties and signals:
        readonly property var holdingTypes: [
            HoldingTypes.Type.Asset, HoldingTypes.Type.Collectible, HoldingTypes.Type.Ens
        ]
        readonly property var tabsModel: [qsTr("Assets"), qsTr("Collectibles"), qsTr("ENS")]
        readonly property var tabsModelNoEns: [qsTr("Assets"), qsTr("Collectibles")]
        readonly property bool assetsReady: root.assetAmount > 0 && root.assetKey
        readonly property bool collectiblesReady: root.collectibleAmount > 0 && root.collectibleKey
        readonly property bool ensReady: d.ensDomainNameValid

        property int extendedDropdownType: ExtendedDropdownContent.Type.Assets
        property int currentHoldingType: HoldingTypes.Type.Asset

        property bool updateSelected: false

        property int initialHoldingMode: HoldingTypes.Mode.Add
        property int effectiveHoldingMode: initialHoldingMode === HoldingTypes.Mode.UpdateOrRemove
                                           ? HoldingTypes.Mode.UpdateOrRemove
                                           : (updateSelected ? HoldingTypes.Mode.Update : HoldingTypes.Mode.Add)

        property bool extendedDeepNavigation: false
        property bool allTokensMode: false

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
        readonly property int bottomInset: 20

        function setInitialFlow() {
            statesStack.clear()
            if(d.currentHoldingType !== HoldingTypes.Type.Ens)
                statesStack.push(HoldingsDropdown.FlowType.List_Deep1)
            else
                statesStack.push(HoldingsDropdown.FlowType.Selected)
        }

        function setDefaultAmounts() {
            d.assetAmountText = ""
            d.collectibleAmountText = ""
            root.assetAmount = 0
            root.collectibleAmount = 1
        }

        function forceLayout() {
            root.height = 0         //setting height to 0 before because Popup cannot properly resize if the current contentHeight exceeds the available height
            root.height = undefined //use implicit height
        }
    }

    StatesStack {
        id: statesStack
    }

    width: d.defaultWidth
    padding: d.padding
    bottomInset: d.bottomInset
    bottomPadding: d.padding + d.bottomInset

    contentItem: ColumnLayout {
        id: content

        spacing: d.backButtonToContentSpace
        state: statesStack.currentState

        StatusIconTextButton {
            id: backButton

            Layout.preferredWidth: d.backButtonWidth
            Layout.preferredHeight: d.backButtonHeight
            visible: statesStack.size > 1
            spacing: 0
            leftPadding: 4
            statusIcon: "previous"
            icon.width: 12
            icon.height: 12
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
                    PropertyChanges {target: d; extendedDropdownType: ExtendedDropdownContent.Type.Assets}
                },
                State {
                    name: HoldingTypes.Type.Collectible
                    PropertyChanges {target: loader; sourceComponent: listLayout}
                    PropertyChanges {target: d; extendedDropdownType: ExtendedDropdownContent.Type.Collectibles}
                },
                State {
                    name: HoldingTypes.Type.Ens
                    PropertyChanges {target: loader; sourceComponent: ensLayout}
                }
            ]

            onCurrentIndexChanged: {
                if(currentIndex >= 0) {
                    d.currentHoldingType = d.holdingTypes[currentIndex]
                    d.setInitialFlow()
                }
            }

            Repeater {
                id: tabLabelsRepeater
                model: root.isENSTab ? d.tabsModel : d.tabsModelNoEns

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
            onItemChanged: d.forceLayout()
        }

        states: [
            State {
                name: HoldingsDropdown.FlowType.Selected
                PropertyChanges {
                    target: loader
                    sourceComponent: {
                        if (d.currentHoldingType === HoldingTypes.Type.Asset)
                            return assetLayout
                        if (d.currentHoldingType === HoldingTypes.Type.Collectible)
                            return collectibleLayout
                        return ensLayout
                    }
                }
            },
            State {
                name: HoldingsDropdown.FlowType.List_Deep1
                PropertyChanges {target: loader; sourceComponent: listLayout}
                PropertyChanges {target: d; extendedDeepNavigation: false}
            },
            State {
                name: HoldingsDropdown.FlowType.List_Deep1_All
                extend: HoldingsDropdown.FlowType.List_Deep1
                PropertyChanges {target: d; extendedDeepNavigation: false; allTokensMode: true }
            },
            State {
                name: HoldingsDropdown.FlowType.List_Deep2
                extend: HoldingsDropdown.FlowType.List_Deep1
                PropertyChanges {target: d; extendedDeepNavigation: true}
            }
        ]
    }

    onClosed: root.reset()
    onIsENSTabChanged: root.reset()

    Component {
        id: listLayout

        ExtendedDropdownContent {
            id: listPanel

            communityId: root.communityId
            assetsModel: root.assetsModel
            collectiblesModel: root.collectiblesModel
            noDataText: root.noDataText

            checkedKeys: root.usedTokens.map(entry => entry.key)
            type: d.extendedDropdownType
            showAllTokensMode: d.allTokensMode

            Binding on showAllTokensMode {
                value: true

                when: d.extendedDropdownType === ExtendedDropdownContent.Type.Assets
                      && root.assetsModel.rowCount() > 0
                      && ModelUtils.get(root.assetsModel, 0, "category") === TokenCategories.Category.General
            }

            Binding on showAllTokensMode {
                value: true

                when: d.extendedDropdownType === ExtendedDropdownContent.Type.Collectibles
                      && root.collectiblesModel.rowCount() > 0
                      && ModelUtils.get(root.collectiblesModel, 0, "category") === TokenCategories.Category.General
            }

            onTypeChanged: forceActiveFocus()            

            onItemClicked: {
                d.assetAmountText = ""
                d.collectibleAmountText = ""

                if (checkedKeys.includes(key)) {
                    const amount = root.usedTokens.find(entry => entry.key === key).amount

                    if(d.extendedDropdownType === ExtendedDropdownContent.Type.Assets)
                        root.assetAmount = amount
                    else
                        root.collectibleAmount = amount

                    d.updateSelected = true
                } else {
                    d.setDefaultAmounts()
                    d.updateSelected = false
                }

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

            onFooterButtonClicked: statesStack.push(
                                       HoldingsDropdown.FlowType.List_Deep1_All)

            onLayoutChanged: d.forceLayout()

            Component.onCompleted: {
                if(d.extendedDeepNavigation)
                    listPanel.goForward(d.currentItemKey,
                                        PermissionsHelpers.getTokenNameByKey(root.collectiblesModel, d.currentItemKey),
                                        PermissionsHelpers.getTokenIconByKey(root.collectiblesModel, d.currentItemKey),
                                        d.currentSubItems)
            }

            onNavigateToMintTokenSettings: root.navigateToMintTokenSettings(type === ExtendedDropdownContent.Type.Assets)

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

            tokenName: PermissionsHelpers.getTokenNameByKey(root.assetsModel, root.assetKey)
            tokenShortName: PermissionsHelpers.getTokenShortNameByKey(root.assetsModel, root.assetKey)
            tokenImage: PermissionsHelpers.getTokenIconByKey(root.assetsModel, root.assetKey)
            amountText: d.assetAmountText
            tokenCategoryText: qsTr("Asset")
            addOrUpdateButtonEnabled: d.assetsReady
            mode: d.effectiveHoldingMode

            ListModel {
                Component.onCompleted: {
                    const asset = PermissionsHelpers.getTokenByKey(
                                    root.assetsModel,
                                    root.assetKey)

                    if (!asset)
                        return

                    const chainName = asset.chainName ?? ""
                    const chainIcon = asset.chainIcon
                                    ? Style.svg(asset.chainIcon) : ""

                    if (!chainName)
                        return

                    append({
                        name:chainName,
                        icon: chainIcon,
                        amount: asset.supply,
                        infiniteAmount: asset.infiniteSupply
                    })

                    assetPanel.networksModel = this
                }
            }

            onEffectiveAmountChanged: root.assetAmount = effectiveAmount
            onAmountTextChanged: d.assetAmountText = amountText
            onAddClicked: root.addAsset(root.assetKey, root.assetAmount)
            onUpdateClicked: root.updateAsset(root.assetKey, root.assetAmount)
            onRemoveClicked: root.removeClicked()

            Connections {
                target: backButton

                function onClicked() { statesStack.pop() }
            }

            Component.onCompleted: {
                if (d.assetAmountText.length === 0 && root.assetAmount)
                    assetPanel.setAmount(root.assetAmount)
            }
        }
    }

    Component {
        id: collectibleLayout

        TokenPanel {
            id: collectiblePanel

            readonly property real effectiveAmount: amountValid ? amount : 0

            tokenName: PermissionsHelpers.getTokenNameByKey(root.collectiblesModel, root.collectibleKey)
            tokenShortName: ""
            tokenImage: PermissionsHelpers.getTokenIconByKey(root.collectiblesModel, root.collectibleKey)
            tokenAmount: PermissionsHelpers.getTokenAmountByKey(root.collectiblesModel, root.collectibleKey)
            amountText: d.collectibleAmountText
            tokenCategoryText: qsTr("Collectible")
            addOrUpdateButtonEnabled: d.collectiblesReady
            allowDecimals: false
            mode: d.effectiveHoldingMode

            ListModel {
                Component.onCompleted: {
                    const collectible = PermissionsHelpers.getTokenByKey(
                                          root.collectiblesModel,
                                          root.collectibleKey)

                    if (!collectible)
                        return

                    const chainName = collectible.chainName ?? ""
                    const chainIcon = collectible.chainIcon
                                    ? Style.svg(collectible.chainIcon) : ""

                    if (!chainName)
                        return

                    append({
                        name:chainName,
                        icon: chainIcon,
                        amount: collectible.supply,
                        infiniteAmount: collectible.infiniteSupply
                    })

                    collectiblePanel.networksModel = this
                }
            }

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
            mode: d.initialHoldingMode
            reservedNames: root.usedEnsNames

            onDomainNameChanged: root.ensDomainName = domainName
            onDomainNameValidChanged: d.ensDomainNameValid = domainNameValid
            onAddClicked: root.addEns(root.ensDomainName)
            onUpdateClicked: root.updateEns(root.ensDomainName)
            onRemoveClicked: root.removeClicked()
        }
    }
}
