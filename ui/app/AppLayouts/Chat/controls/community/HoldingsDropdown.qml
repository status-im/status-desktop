import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1 as SQ

StatusDropdown {
    id: root

    property var store

    property var itemKey
    property real tokenAmount: 0
    property string tokenName: d.defaultTokenNameText
    property url tokenImage: ""
    property real collectibleAmount: 1
    property string collectibleName: d.defaultCollectibleNameText
    property bool collectiblesSpecificAmount: false

    property int ensType: EnsPanel.EnsType.Any
    property string ensDomainName: ""
    property bool ensDomainNameValid: false

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
        root.collectiblesSpecificAmount = false
        root.ensType = EnsPanel.EnsType.Any
        root.ensDomainName = ""
        root.operator = SQ.Utils.Operators.None
    }

    padding: d.padding

    onOpened: d.selectInitState()
    onClosed: root.reset()
    onWithOperatorSelectorChanged: d.selectInitState()

    QtObject {
        id: d

        // Internal management properties:
        readonly property bool tokensReady: root.tokenAmount > 0 && root.tokenName !== d.defaultTokenNameText
        readonly property bool collectiblesReady: root.collectibleAmount > 0 && root.collectibleName !== d.defaultCollectibleNameText
        readonly property bool ensReady: root.ensType === EnsPanel.EnsType.Any || root.ensDomainNameValid

        readonly property string operatorsState: "OPERATORS"
        readonly property string tabsState: "TABS"
        readonly property string extendedState: "EXTENDED"

        readonly property string tokensState: "TOKENS"
        readonly property string collectiblesState: "COLLECTIBLES"
        readonly property string ensState: "ENS"

        property int extendedDropdownType: ExtendedDropdownContent.Type.Tokens
        property int currentTabIndex: 0

        // By design values:
        readonly property int padding: 8
        readonly property int topPaddingWithBack: 12
        readonly property int extendedTopPadding: 16

        readonly property int operatorsWidth: 159
        readonly property int operatorsHeight: 96

        readonly property int defaultWidth: 289
        readonly property int defaultHeight: 232
        readonly property int enlargedHeight: 276
        readonly property int extendedHeight: 417

        readonly property int backButtonExtraLeftMargin: 4

        property string defaultTokenNameText: qsTr("Choose token")
        property string defaultCollectibleNameText: qsTr("Choose collectible")

        signal addClicked

        function selectInitState() {
            if(root.withOperatorSelector)
                content.state = d.operatorsState
            else
                content.state = d.tabsState
        }
    }

    contentItem: ColumnLayout {
        id: content

        spacing: 10

        StatusIconTextButton {
            id: backButton

            Layout.leftMargin: d.backButtonExtraLeftMargin
            spacing: 0
            statusIcon: "next"
            icon.width: 12
            icon.height: 12
            iconRotation: 180
            text: qsTr("Back")
        }

        Loader {
            id: loader
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        states: [
            State {
                name: d.operatorsState
                PropertyChanges {target: loader; sourceComponent: operatorsSelectorView}
                PropertyChanges {target: backButton; visible: false}
                PropertyChanges {target: root; width: d.operatorsWidth; height: d.operatorsHeight }
            },
            State {
                name: d.tabsState
                PropertyChanges {target: loader; sourceComponent: tabsView}
                PropertyChanges {target: backButton; visible: root.withOperatorSelector}
                PropertyChanges {
                    target: root; topPadding: root.withOperatorSelector ? d.topPaddingWithBack : d.extendedTopPadding
                    width: d.defaultWidth
                    height: (loader.item.state === d.collectiblesState && root.collectiblesSpecificAmount)
                            || (loader.item.state === d.ensState && root.ensType === EnsPanel.EnsType.CustomSubdomain) ? d.enlargedHeight : d.defaultHeight
                }
            },
            State {
                name: d.extendedState
                PropertyChanges {target: loader; sourceComponent: extendedView}
                PropertyChanges {target: backButton; visible: true}
                PropertyChanges {target: root; topPadding: d.topPaddingWithBack; width: d.defaultWidth; height: d.extendedHeight}
            }
        ]
    }

    Component {
        id: operatorsSelectorView

        OperatorsSelector {
            onOperatorSelected: {
                root.operator = operator
                content.state = d.tabsState
            }
        }
    }

    Component {
        id: tabsView

        HoldingsTabs {
            id: holdingsTabs

            states: [
                State {
                    name: d.tokensState
                    PropertyChanges {target: holdingsTabs; sourceComponent: tokensLayout; addButtonEnabled: d.tokensReady}
                },
                State {
                    name: d.collectiblesState
                    PropertyChanges {target: holdingsTabs; sourceComponent: collectiblesLayout; addButtonEnabled: d.collectiblesReady}
                },
                State {
                    name: d.ensState
                    PropertyChanges {target: holdingsTabs; sourceComponent: ensLayout; addButtonEnabled: d.ensReady}
                }
            ]

            tabLabels: [qsTr("Token"), qsTr("Collectible"), qsTr("ENS")]
            state: [d.tokensState, d.collectiblesState, d.ensState][currentIndex]

            currentIndex: d.currentTabIndex
            onCurrentIndexChanged: d.currentTabIndex = currentIndex

            onAddClicked: d.addClicked()

            Connections {
                target: backButton

                function onClicked() {
                    content.state = d.operatorsState
                }
            }
        }
    }

    Component {
        id: tokensLayout

        TokensPanel {
            id: tokensPanel

            tokenName: root.tokenName
            tokenImage: root.tokenImage
            amount: root.tokenAmount === 0 ? "" : root.tokenAmount.toString()
            onAmountChanged: root.tokenAmount = Number(amount)

            onPickerClicked: {
                d.extendedDropdownType = ExtendedDropdownContent.Type.Tokens
                content.state = d.extendedState
            }

            Connections {
                target: d

                function onAddClicked() {
                    root.addItem(root.itemKey, qsTr("%1 %2").arg(root.tokenAmount.toString()).arg(root.tokenName),
                                 root.tokenImage, root.operator)
                }
            }
        }
    }

    Component {
        id: collectiblesLayout

        CollectiblesPanel {
            collectibleName: root.collectibleName
            collectibleImage: root.collectibleImage
            amount: root.collectibleAmount === 0 ? "" : root.collectibleAmount.toString()
            onAmountChanged: root.collectibleAmount = Number(amount)

            specificAmount: root.collectiblesSpecificAmount
            onSpecificAmountChanged: root.collectiblesSpecificAmount = specificAmount

            onPickerClicked: {
                d.extendedDropdownType = ExtendedDropdownContent.Type.Collectibles
                content.state = d.extendedState
            }

            Connections {
                target: d

                function onAddClicked() {
                    root.addItem(root.itemKey, qsTr("%1 %2").arg(root.collectibleAmount.toString()).arg(root.collectibleName),
                                 root.tokenImage, root.operator)
                }
            }
        }
    }

    Component {
        id: ensLayout

        EnsPanel {
            ensType: root.ensType
            onEnsTypeChanged: root.ensType = ensType

            domainName: root.ensDomainName
            onDomainNameChanged: root.ensDomainName = domainName
            onDomainNameValidChanged: root.ensDomainNameValid = domainNameValid

            Connections {
                target: d

                function onAddClicked() {
                    const icon = "qrc:imports/assets/icons/profile/ensUsernames.svg"

                    if (root.ensType === EnsPanel.EnsType.Any) {
                        root.addItem("EnsAny", qsTr("Any ENS username"), icon,
                                     root.operator)
                    } else {
                        root.addItem("EnsAny", qsTr(`ENS username on '%1' domain`).arg(root.ensDomainName), icon,
                                     root.operator)
                    }
                }
            }
        }
    }

    Component {
        id: extendedView

        ExtendedDropdownContent {
            id: extendedDropdown

            store: root.store
            type: d.extendedDropdownType

            onItemClicked: {
                // Go back
                content.state = d.tabsState

                if(d.extendedDropdownType === ExtendedDropdownContent.Type.Tokens) {
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

            Connections {
                target: backButton

                function onClicked() {
                    if (extendedDropdown.canGoBack)
                        extendedDropdown.goBack()
                    else
                        content.state = d.tabsState
                }
            }
        }
    }    
}
