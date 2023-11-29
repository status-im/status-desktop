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
        if(d.currentHoldingType  ===  Constants.TokenType.ERC20)
            return noDataTextForAssets
        if(d.currentHoldingType === Constants.TokenType.ERC721)
            return noDataTextForCollectibles
        return qsTr("No data found")
    }
    property string noDataTextForAssets: qsTr("No assets found")
    property string noDataTextForCollectibles: qsTr("No collectibles found")

    property alias allTokensMode: d.allTokensMode

    property var usedTokens: []
    property var usedEnsNames: []

    property string assetKey: ""
    property string assetAmount: "0"
    property int assetMultiplierIndex: 0

    property string collectibleKey: ""
    property string collectibleAmount: "1"

    property string ensDomainName: ""
    property bool showTokenAmount: true

    signal addAsset(string key, string amount)
    signal addCollectible(string key, string amount)
    signal addEns(string domain)

    signal updateAsset(string key, string amount)
    signal updateCollectible(string key, string amount)
    signal updateEns(string domain)

    signal removeClicked
    signal navigateToMintTokenSettings(bool isAssetType)

    enum FlowType {
        Selected, List_Deep1, List_Deep1_All, List_Deep2
    }

    function openUpdateFlow() {
        d.initialHoldingMode = HoldingTypes.Mode.UpdateOrRemove
        if(d.currentHoldingType !== Constants.TokenType.ENS) {
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
        d.currentHoldingType = Constants.TokenType.ERC20
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
            Constants.TokenType.ERC20, Constants.TokenType.ERC721, Constants.TokenType.ENS
        ]
        readonly property var tabsModel: [qsTr("Assets"), qsTr("Collectibles"), qsTr("ENS")]
        readonly property var tabsModelNoEns: [qsTr("Assets"), qsTr("Collectibles")]

        readonly property bool assetsReady: root.assetAmount !== "0" && root.assetKey
        readonly property bool collectiblesReady: root.collectibleAmount !== "0" && root.collectibleKey

        readonly property bool ensReady: d.ensDomainNameValid

        property int extendedDropdownType: ExtendedDropdownContent.Type.Assets
        property int currentHoldingType: Constants.TokenType.ERC20

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
        readonly property int tabBarHeight: 36
        readonly property int tabBarTextSize: 13
        readonly property int backButtonWidth: 56
        readonly property int backButtonHeight: 24
        readonly property int backButtonToContentSpace: 8
        readonly property int bottomInset: 20

        function setInitialFlow() {
            statesStack.clear()
            if(d.currentHoldingType !== Constants.TokenType.ENS)
                statesStack.push(HoldingsDropdown.FlowType.List_Deep1)
            else
                statesStack.push(HoldingsDropdown.FlowType.Selected)
        }

        function setDefaultAmounts() {
            d.assetAmountText = ""
            d.collectibleAmountText = ""
            root.assetAmount = "0"
            root.collectibleAmount = "1"
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
    leftPadding: 0
    rightPadding: 0
    topPadding: d.padding
    bottomInset: d.bottomInset
    bottomPadding: d.bottomInset + (loader.sourceComponent == listLayout ? 0 : d.padding)

    contentItem: ColumnLayout {
        id: content

        spacing: d.backButtonToContentSpace
        state: statesStack.currentState

        StatusIconTextButton {
            id: backButton

            Layout.preferredWidth: d.backButtonWidth
            Layout.preferredHeight: d.backButtonHeight
            Layout.leftMargin: d.padding
            Layout.rightMargin: d.padding
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
            Layout.preferredHeight: d.tabBarHeight
            Layout.fillWidth: true
            Layout.leftMargin: d.padding
            Layout.rightMargin: d.padding
            currentIndex: d.holdingTypes.indexOf(d.currentHoldingType)
            state: d.currentHoldingType
            states: [
                State {
                    name: Constants.TokenType.ERC20
                    PropertyChanges {target: loader; sourceComponent: listLayout}
                    PropertyChanges {target: d; extendedDropdownType: ExtendedDropdownContent.Type.Assets}
                },
                State {
                    name: Constants.TokenType.ERC721
                    PropertyChanges {target: loader; sourceComponent: listLayout}
                    PropertyChanges {target: d; extendedDropdownType: ExtendedDropdownContent.Type.Collectibles}
                },
                State {
                    name: Constants.TokenType.ENS
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
            Layout.leftMargin: loader.sourceComponent == listLayout ? 0 : d.padding
            Layout.rightMargin: loader.sourceComponent == listLayout ? 0 : d.padding
            Layout.fillHeight: true
            onItemChanged: d.forceLayout()
        }

        states: [
            State {
                name: HoldingsDropdown.FlowType.Selected
                PropertyChanges {
                    target: loader
                    sourceComponent: {
                        if (d.currentHoldingType === Constants.TokenType.ERC20)
                            return assetLayout
                        if (d.currentHoldingType === Constants.TokenType.ERC721)
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
            showTokenAmount: root.showTokenAmount

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
                {
                    root.collectibleKey = key
                    const item = PermissionsHelpers.getTokenByKey(root.collectiblesModel, root.collectibleKey)

                    //When the collectible is unique, there is no need for the user to select amount
                    //Just send the add/update events
                    if((item.supply && item.supply.toString() === "1")
                            || (item.remainingSupply && item.remainingSupply.toString() === "1")) {
                        root.collectibleAmount = "1"
                        d.updateSelected ? root.updateCollectible(root.collectibleKey, "1")
                                         : root.addCollectible(root.collectibleKey, "1")
                        return
                    }
                }

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

            readonly property string effectiveAmount: amountValid ? amount : "0"
            property bool completed: false

            tokenName: PermissionsHelpers.getTokenNameByKey(root.assetsModel, root.assetKey)
            tokenShortName: PermissionsHelpers.getTokenShortNameByKey(root.assetsModel, root.assetKey)
            tokenImage: PermissionsHelpers.getTokenIconByKey(root.assetsModel, root.assetKey)
            tokenAmount: PermissionsHelpers.getTokenRemainingSupplyByKey(root.assetsModel, root.assetKey)
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
                        name: chainName,
                        icon: chainIcon,
                        amount: asset.remainingSupply,
                        multiplierIndex: asset.multiplierIndex,
                        infiniteAmount: asset.infiniteSupply
                    })

                    assetPanel.networksModel = this
                }
            }

            onEffectiveAmountChanged: {
                if (completed)
                    root.assetAmount = effectiveAmount
            }

            onMultiplierIndexChanged: root.assetMultiplierIndex = multiplierIndex
            onAmountTextChanged: d.assetAmountText = amountText
            onAddClicked: root.addAsset(root.assetKey, root.assetAmount)
            onUpdateClicked: root.updateAsset(root.assetKey, root.assetAmount)
            onRemoveClicked: root.removeClicked()

            Connections {
                target: backButton

                function onClicked() { statesStack.pop() }
            }

            Component.onCompleted: {
                completed = true

                if (d.assetAmountText.length === 0 && root.assetAmount !== "0")
                    assetPanel.setAmount(root.assetAmount,
                                         root.assetMultiplierIndex)
            }
        }
    }

    Component {
        id: collectibleLayout

        TokenPanel {
            id: collectiblePanel

            readonly property string effectiveAmount: amountValid ? amount : "0"
            property bool completed: false

            tokenName: PermissionsHelpers.getTokenNameByKey(root.collectiblesModel, root.collectibleKey)
            tokenShortName: ""
            tokenImage: PermissionsHelpers.getTokenIconByKey(root.collectiblesModel, root.collectibleKey)
            tokenAmount: PermissionsHelpers.getTokenRemainingSupplyByKey(root.collectiblesModel, root.collectibleKey)
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
                        amount: collectible.remainingSupply,
                        multiplierIndex: collectible.multiplierIndex,
                        infiniteAmount: collectible.infiniteSupply
                    })

                    collectiblePanel.networksModel = this
                }
            }

            onEffectiveAmountChanged: {
                if (completed)
                    root.collectibleAmount = effectiveAmount
            }

            onAmountTextChanged: d.collectibleAmountText = amountText
            onAddClicked: root.addCollectible(root.collectibleKey, root.collectibleAmount)
            onUpdateClicked: root.updateCollectible(root.collectibleKey, root.collectibleAmount)
            onRemoveClicked: root.removeClicked()

            Component.onCompleted: {
                completed = true

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
