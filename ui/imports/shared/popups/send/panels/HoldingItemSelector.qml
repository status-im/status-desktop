import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import SortFilterProxyModel 0.2

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Backpressure 1.0

import shared.controls 1.0
import utils 1.0

Item {
    id: root

    property var comboBoxModel

    property var selectedItem
    property var hoveredItem
    property string defaultIconSource
    property string placeholderText

    property var itemIconSourceFn: function (item) {
        return ""
    }

    property var itemTextFn: function (item) {
        return ""
    }

    property alias comboBoxControl: comboBox.control
    property alias comboBoxDelegate: comboBox.delegate
    property var comboBoxPopupHeader

    property int contentIconSize: 21
    property int contentTextSize: 28

    function resetInternal() {
        items = null
        selectedItem = null
        hoveredItem = null
    }

    function openPopup() {
        root.comboBoxControl.popup.open()
    }

    implicitWidth: comboBox.width
    implicitHeight: comboBox.implicitHeight

    onSelectedItemChanged: {
        d.iconSource = itemIconSourceFn(selectedItem) ?? defaultIconSource
        d.text = itemTextFn(selectedItem) ?? placeholderText
    }

    onHoveredItemChanged: {
        d.iconSource = itemIconSourceFn(hoveredItem) ?? defaultIconSource
        d.text = itemTextFn(hoveredItem) ?? placeholderText
    }

    QtObject {
        id: d

        property string iconSource: ""
        onIconSourceChanged: tokenIcon.image.source = iconSource
        property string text: ""
        readonly property bool isItemSelected: !!root.selectedItem || !!root.hoveredItem

    }

    StatusComboBox {
        id: comboBox
        objectName: "assetSelectorButton"

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        width: Math.min(implicitWidth, parent.width)

        control.padding: 4
        control.popup.width: 492
        control.popup.x: -root.x
        control.popup.verticalPadding: 0

        popupContentItemObjectName: "assetSelectorList"

        model: root.comboBoxModel

        control.background: Rectangle {
            color: "transparent"
            border.width: d.isItemSelected ? 0 : 1
            border.color: Theme.palette.directColor7
            radius: 12
        }

        contentItem: RowLayout {
            id: rowLayout
            implicitHeight: 38
            StatusRoundedImage {
                id: tokenIcon
                Layout.preferredWidth: root.contentIconSize
                Layout.preferredHeight: root.contentIconSize
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                visible: !!d.iconSource
                image.source: d.iconSource
                image.onStatusChanged: {
                    if (image.status === Image.Error) {
                        image.source = root.defaultIconSource
                    }
                }
            }
            StatusBaseText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: root.contentTextSize
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.miscColor1
                text: d.text
                visible: d.isItemSelected
            }
            StatusIcon {
                Layout.leftMargin: -3
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                icon: "chevron-down"
                color: Theme.palette.miscColor1
                visible: !!root.selectedItem
            }
        }

        control.indicator: null

        Component.onCompleted: {
            control.currentIndex = -1
            control.popup.contentItem.header = root.comboBoxPopupHeader
        }

        control.popup.onOpened: {
            control.currentIndex = -1
        }
    }
}
