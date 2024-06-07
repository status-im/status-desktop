import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

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
    property alias comboBoxListViewSection: comboBox.comboBoxListViewSection
    property var comboBoxPopupHeader

    property int contentIconSize: 21
    property int contentTextSize: 28

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
        property string text: qsTr("Select asset")
        readonly property bool isItemSelected: !!root.selectedItem || !!root.hoveredItem
    }

    StatusComboBox {
        id: comboBox
        objectName: "assetSelectorButton"

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        control.padding: 12
        control.popup.width: 492
        control.popup.x: -root.x
        control.popup.verticalPadding: 0

        popupContentItemObjectName: "assetSelectorList"

        model: root.comboBoxModel

        control.background: Rectangle {
            color: !d.isItemSelected ? Theme.palette.primaryColor3 : "transparent"
            border.width: d.isItemSelected ? 0 : 1
            border.color: Theme.palette.directColor7
            radius: 8

            HoverHandler {
                cursorShape: root.enabled ? Qt.PointingHandCursor : undefined
            }
        }

        contentItem: RowLayout {
            StatusRoundedImage {
                id: tokenIcon
                Layout.preferredWidth: root.contentIconSize
                Layout.preferredHeight: root.contentIconSize
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
                font.pixelSize: root.contentTextSize
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.primaryColor1
                text: d.text
            }
            StatusIcon {
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                icon: "chevron-down"
                color: Theme.palette.primaryColor1
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
