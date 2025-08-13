import QtQuick
import QtQuick.Layouts
import QtQml

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components.private as SQP
import StatusQ.Core.Utils as SQUtils

import SortFilterProxyModel

StatusComboBox {
    id: root

    readonly property string currentName: control.currentText
    readonly property alias currentAmount: instantiator.amount
    readonly property alias decimals: instantiator.decimals
    readonly property alias currentMultiplierIndex: instantiator.multiplierIndex
    readonly property alias currentInfiniteAmount: instantiator.infiniteAmount
    readonly property alias currentIcon: instantiator.icon

    type: StatusComboBox.Type.Secondary
    size: StatusComboBox.Size.Small

    height: 48

    control.enabled: !d.oneItem
    control.padding: d.padding
    control.spacing: d.padding
    control.textRole: "name"
    control.currentIndex: 0
    control.indicator.visible: !d.oneItem

    control.background: SQP.StatusComboboxBackground {
        active: false
        visible: !d.oneItem
    }

    QtObject {
        id: d

        readonly property bool oneItem: control.count === 1

        readonly property int padding: 8
        readonly property int radius: 8
        readonly property int fontSize: Theme.additionalTextSize
        readonly property int iconSize: 32

        readonly property string infinitySymbol: "∞"

        function amountText(amount, multiplierIndex) {
            return SQUtils.AmountsArithmetic.toNumber(amount, multiplierIndex)
        }
    }

    component CustomText: StatusBaseText {
        color: Theme.palette.baseColor1
        font.pixelSize: d.fontSize
        font.weight: Font.Medium
        elide: Text.ElideRight
    }

    component DelegateItem: StatusItemDelegate {
        property alias title: titleText.text
        property alias amount: amountText.text
        property alias iconSource: icon.source

        padding: 0
        radius: d.radius

        contentItem: RowLayout {
            spacing: d.padding

            StatusIcon {
                id: icon

                Layout.preferredWidth: d.iconSize
                Layout.preferredHeight: d.iconSize
            }

            CustomText {
                id: titleText

                Layout.fillWidth: true
            }

            CustomText {
                id: amountText
            }
        }
    }

    Instantiator {
        id: instantiator

        property string icon
        property string amount
        property int multiplierIndex
        property bool infiniteAmount
        property int decimals

        model: SortFilterProxyModel {
            sourceModel: root.model
            filters: IndexFilter {
                minimumIndex: root.currentIndex
                maximumIndex: root.currentIndex
            }
        }
        delegate: QtObject {
            component Bind: Binding { target: instantiator }
            readonly property list<Binding> bindings: [
                Bind { property: "icon"; value: model.icon },
                Bind { property: "amount"; value: model.amount },
                Bind { property: "decimals"; value: model.decimals },
                Bind { property: "multiplierIndex"; value: model.multiplierIndex },
                Bind { property: "infiniteAmount"; value: model.infiniteAmount }
            ]
        }
    }

    contentItem: DelegateItem {
        title: root.control.displayText
        iconSource: instantiator.icon

        amount: {
            if (d.oneItem || !instantiator.amount)
                return ""

            if (instantiator.infiniteAmount)
                return d.infinitySymbol

            return d.amountText(instantiator.amount,
                                instantiator.multiplierIndex)
        }

        cursorShape: d.oneItem ? Qt.ArrowCursor : Qt.PointingHandCursor

        onClicked: {
            if (root.oneItem)
                return

            root.control.popup.open()
        }
    }

    delegate: DelegateItem {
        title: model.name
        iconSource: model.icon
        amount: model.infiniteAmount
                ? d.infinitySymbol
                : d.amountText(model.amount, model.multiplierIndex)

        width: parent.width
        height: root.height
        horizontalPadding: d.padding

        highlighted: root.control.highlightedIndex === index

        onClicked: {
            root.currentIndex = index
            root.control.popup.close()
        }
    }
}
