import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.0

import StatusQ 0.1
import StatusQ.Components 0.1
import StatusQ.Components.private 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1

import AppLayouts.Wallet.views 1.0

import utils 1.0
import shared.controls 1.0

ComboBox {
    id: root

    // expected model structure:
    // tokensKey, name, symbol, decimals, currencyBalanceAsString (computed), marketDetails, balances -> [ chainId, address, balance, iconUrl ]

    // input API
    property string nonInteractiveDelegateKey

    // output API
    readonly property string currentTokensKey: d.currentTokensKey
    readonly property alias searchString: searchBox.text

    /**
      Emitted when a token gets selected
      */
    signal tokenSelected(string tokensKey)

    // manipulation
    function selectToken(tokensKey) {
        const idx = ModelUtils.indexOf(model, "tokensKey", tokensKey)
        if (idx === -1) {
            console.warn("TokenSelector::selectToken: unknown tokensKey:", tokensKey)
            tokensKey = ""
        }

        currentIndex = idx
        d.currentTokensKey = tokensKey
        root.tokenSelected(tokensKey)
    }

    function reset() {
        selectToken("")
    }

    QtObject {
        id: d

        // NB: internal tracking; the ComboBox currentValue is not persistent,
        // i.e. relying on currentValue is not safe
        property string currentTokensKey

        readonly property bool isTokenSelected: !!currentTokensKey

        // NB: handle cases when our currently selected token disappears from the model -> reset
        readonly property Connections _conn: Connections {
            target: model ?? null
            function onModelReset() {
                if (d.isTokenSelected && !root.popup.opened)
                    root.selectToken(d.currentTokensKey)
            }
            function onRowsRemoved() {
                if (d.isTokenSelected && !root.popup.opened)
                    root.selectToken(d.currentTokensKey)
            }
        }
    }

    font.family: Theme.palette.baseFont.name
    font.pixelSize: Style.current.additionalTextSize
    spacing: Style.current.halfPadding
    verticalPadding: 10
    leftPadding: 12
    rightPadding: leftPadding + indicator.width + spacing
    opacity: enabled ? 1 : 0.3

    popup.width: 380
    popup.x: root.width - popup.width
    popup.y: root.height
    popup.margins: Style.current.halfPadding
    popup.background: Rectangle {
        color: Theme.palette.statusSelect.menuItemBackgroundColor
        radius: Style.current.radius
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12
            samples: 25
            spread: 0.2
            color: Theme.palette.dropShadow
        }
    }
    popup.contentItem: ColumnLayout {
        spacing: 0
        SearchBox {
            Layout.fillWidth: true
            id: searchBox
            objectName: "searchBox"

            input.leftPadding: root.leftPadding
            input.rightPadding: root.leftPadding
            minimumHeight: 56
            maximumHeight: 56
            placeholderText: qsTr("Search asset name or symbol")
            input.showBackground: false
            focus: visible
            onVisibleChanged: if (!visible) input.edit.clear()
        }
        StatusDialogDivider {
            Layout.fillWidth: true
            visible: listview.count
        }
        StatusListView {
            id: listview
            objectName: "tokenSelectorListview"
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
            Layout.fillHeight: true

            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex

            section.property: "sectionName"
            section.delegate: StatusBaseText {
                required property string section
                width: parent.width
                elide: Text.ElideRight
                text: section
                color: Theme.palette.baseColor1
                padding: Style.current.padding
            }
        }
    }

    background: StatusComboboxBackground {
        border.width: 0
        color: {
            if (d.isTokenSelected)
                return "transparent"
            return root.hovered ? Theme.palette.primaryColor2 : Theme.palette.primaryColor3
        }
    }

    contentItem: Loader {
        height: 40 // by design
        sourceComponent: d.isTokenSelected ? iconTextContentItem : textContentItem
    }

    indicator: StatusComboboxIndicator {
        anchors.right: parent.right
        anchors.rightMargin: root.leftPadding
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.palette.primaryColor1
    }

    delegate: TokenSelectorAssetDelegate {
        required property var model
        required property int index

        highlighted: tokensKey === d.currentTokensKey
        interactive: tokensKey !== root.nonInteractiveDelegateKey

        tokensKey: model.tokensKey
        name: model.name
        symbol: model.symbol
        currencyBalanceAsString: model.currencyBalanceAsString
        balancesModel: model.balances

        onAssetSelected: (tokensKey) => root.selectToken(tokensKey)
    }

    Component {
        id: textContentItem
        StatusBaseText {
            objectName: "holdingSelectorsContentItemText"
            font.pixelSize: root.font.pixelSize
            font.weight: Font.Medium
            color: Theme.palette.primaryColor1
            text: qsTr("Select asset")
        }
    }

    Component {
        id: iconTextContentItem
        RowLayout {
            readonly property string currentSymbol: d.isTokenSelected ? ModelUtils.getByKey(model, "tokensKey", d.currentTokensKey, "symbol")
                                                                      : ""
            spacing: root.spacing
            StatusRoundedImage {
                objectName: "holdingSelectorsTokenIcon"
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                image.source: Constants.tokenIcon(parent.currentSymbol)
            }
            StatusBaseText {
                objectName: "holdingSelectorsContentItemText"
                font.pixelSize: 28
                color: root.hovered ? Theme.palette.blue : Theme.palette.darkBlue
                text: parent.currentSymbol
            }
        }
    }
}
