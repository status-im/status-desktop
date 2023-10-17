import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

import utils 1.0

ComboBox {
    id: root

    property int sortOrder: Qt.DescendingOrder
    readonly property string currentSortRoleName: d.currentSortRoleName

    model: d.predefinedSortModel
    textRole: "text"
    valueRole: "value"
    displayText: !d.isCustomSortOrder ? "%1 %2".arg(currentText).arg(sortOrder === Qt.DescendingOrder ? "↓" : "↑")
                                      : currentText

    Component.onCompleted: currentIndex = indexOfValue(SortOrderComboBox.TokenOrderCustom)

    enum TokenOrder {
        TokenOrderNone = 0,
        TokenOrderCustom,
        TokenOrderValue,
        TokenOrderBalance,
        TokenOrder1WChange,
        TokenOrderAlpha
    }

    horizontalPadding: 12
    verticalPadding: 8
    spacing: 8

    font.family: Theme.palette.baseFont.name
    font.pixelSize: Style.current.additionalTextSize


    QtObject {
        id: d

        readonly property int defaultDelegateHeight: 34

//        // models
//        readonly property SortFilterProxyModel tokensModel: SortFilterProxyModel {
//            sourceModel: root.baseModel
//            proxyRoles: [
//                ExpressionRole {
//                    name: "currentBalance"
//                    expression: model.enabledNetworkBalance.amount
//                },
//                ExpressionRole {
//                    name: "currentCurrencyBalance"
//                    expression: model.enabledNetworkCurrencyBalance.amount
//                }
//            ]
//            sorters: RoleSorter {
//                roleName: cmbTokenOrder.currentSortRoleName
//                sortOrder: cmbTokenOrder.sortOrder
//                enabled: !d.isCustomSortOrder
//            }
//            filters: ValueFilter {
//                roleName: "visibleForNetworkWithPositiveBalance"
//                value: true
//            }
//        }

        readonly property var predefinedSortModel: [
            { value: SortOrderComboBox.TokenOrderValue, text: qsTr("Token value"), icon: "token-sale", sortRoleName: "currentCurrencyBalance" }, // custom SFPM ExpressionRole
            { value: SortOrderComboBox.TokenOrderBalance, text: qsTr("Token balance"), icon: "wallet", sortRoleName: "currentBalance" }, // custom SFPM ExpressionRole
            { value: SortOrderComboBox.TokenOrder1WChange, text: qsTr("1W change"), icon: "time", sortRoleName: "changePct24hour" }, // FIXME changePct1Week role missing in backend!!!
            { value: SortOrderComboBox.TokenOrderAlpha, text: qsTr("Alphabetic"), icon: "bold", sortRoleName: "name" },
            { value: SortOrderComboBox.TokenOrderNone, text: "---", icon: "", sortRoleName: "" },
            { value: SortOrderComboBox.TokenOrderCustom, text: qsTr("Custom order"), icon: "exchange", sortRoleName: "" }
        ]
        readonly property string currentSortRoleName: root.currentIndex !== -1 ? d.predefinedSortModel[root.currentIndex].sortRoleName : ""
        readonly property bool isCustomSortOrder: root.currentValue === SortOrderComboBox.TokenOrderCustom
    }

    background: Rectangle {
        border.width: 1
        border.color: Theme.palette.directColor7
        radius: 8
        color: root.down ? Theme.palette.baseColor2 : "transparent"
        HoverHandler {
            cursorShape: root.enabled ? Qt.PointingHandCursor : undefined
        }
    }

    contentItem: StatusBaseText {
        leftPadding: root.horizontalPadding
        rightPadding: root.horizontalPadding
        font.pixelSize: root.font.pixelSize
        font.weight: Font.Medium
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        text: root.displayText
        color: Theme.palette.baseColor1
    }

    indicator: StatusIcon {
        x: root.mirrored ? root.horizontalPadding : root.width - width - root.horizontalPadding
        y: root.topPadding + (root.availableHeight - height) / 2
        width: 16
        height: width
        icon: "chevron-down"
        color: Theme.palette.baseColor1
    }

    popup: Popup {
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        y: root.height + 4

        implicitWidth: root.width
        margins: 8

        padding: 1
        verticalPadding: 8

        background: Rectangle {
            color: Theme.palette.statusSelect.menuItemBackgroundColor
            radius: 8
            border.color: Theme.palette.baseColor2
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

        contentItem: ColumnLayout {
            StatusBaseText {
                Layout.fillWidth: true
                Layout.preferredHeight: d.defaultDelegateHeight
                text: qsTr("Sort by")
                font.pixelSize: Style.current.tertiaryTextFontSize
                leftPadding: Style.current.padding
                verticalAlignment: Qt.AlignVCenter
                color: Theme.palette.baseColor1
            }
            StatusListView {
                Layout.fillWidth: true
                implicitWidth: contentWidth
                implicitHeight: contentHeight

                model: root.popup.visible ? root.delegateModel : null
                currentIndex: root.highlightedIndex
            }
        }
    }

    Component {
        id: regularMenuComponent
        RowLayout {
            spacing: root.spacing

            StatusIcon {
                visible: !!icon
                icon: iconName
                color: root.enabled ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
                width: 16
                height: 16
            }

            StatusBaseText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: menuText
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                color: root.enabled ? Theme.palette.directColor1 : Theme.palette.baseColor1
                font.pixelSize: root.font.pixelSize
                font.weight: root.currentIndex === menuIndex ? Font.DemiBold : Font.Normal
            }

            Item { Layout.fillWidth: true }

            Row {
                visible: !isCustomOrder
                spacing: 4
                StatusFlatRoundButton {
                    radius: 6
                    width: 24
                    height: 24
                    icon.name: "arrow-up"
                    icon.width: 18
                    icon.height: 18
                    opacity: root.highlightedIndex === menuIndex || highlighted // not "visible, we want the item to stay put
                    highlighted: root.currentIndex === menuIndex && root.sortOrder === Qt.AscendingOrder
                    onClicked: {
                        if (root.currentIndex !== menuIndex)
                            root.currentIndex = menuIndex
                        root.sortOrder = Qt.AscendingOrder
                        root.popup.close()
                    }
                }
                StatusFlatRoundButton {
                    radius: 6
                    width: 24
                    height: 24
                    icon.name: "arrow-down"
                    icon.width: 18
                    icon.height: 18
                    opacity: root.highlightedIndex === menuIndex || highlighted // not "visible, we want the item to stay put
                    highlighted: root.currentIndex === menuIndex && root.sortOrder === Qt.DescendingOrder
                    onClicked: {
                        if (root.currentIndex !== menuIndex)
                            root.currentIndex = menuIndex
                        root.sortOrder = Qt.DescendingOrder
                        root.popup.close()
                    }
                }
            }
        }
    }

    Component {
        id: separatorMenuComponent
        StatusMenuSeparator {}
    }

    delegate: ItemDelegate {
        required property int index
        required property var modelData
        readonly property bool isSeparator: text === "---"

        id: menuDelegate
        width: root.width
        highlighted: root.highlightedIndex === index
        enabled: !isSeparator
        leftPadding: isSeparator ? 0 : 14
        rightPadding: isSeparator ? 0 : 8
        verticalPadding: isSeparator ? 2 : 5
        spacing: root.spacing
        font: root.font
        text: root.textRole ? (Array.isArray(root.model) ? modelData[root.textRole] : model[root.textRole])
                            : modelData
        icon.name: modelData["icon"]
        icon.color: Theme.palette.primaryColor1
        background: Rectangle {
            implicitHeight: parent.isSeparator ? 3 : d.defaultDelegateHeight
            color: {
                if (menuDelegate.index === root.currentIndex)
                    return Theme.palette.primaryColor3
                if (menuDelegate.highlighted)
                    return Theme.palette.statusMenu.hoverBackgroundColor

                return "transparent"
            }
            HoverHandler {
                cursorShape: root.enabled ? Qt.PointingHandCursor : undefined
            }
        }
        contentItem: Loader {
            readonly property int menuIndex: menuDelegate.index
            readonly property string menuText: menuDelegate.text
            readonly property string iconName: menuDelegate.icon.name
            readonly property bool isCustomOrder: !menuDelegate.modelData["sortRoleName"]
            sourceComponent: menuDelegate.isSeparator ? separatorMenuComponent : regularMenuComponent
        }
        onClicked: root.currentIndex = index
    }
}
