import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

import QtQuick.Templates 2.14 as T

Item {
    id: root

    property alias control: comboBox
    property alias model: comboBox.model
    property alias delegate: comboBox.delegate
    property alias contentItem: comboBox.contentItem

    property alias currentIndex: comboBox.currentIndex
    property alias currentValue: comboBox.currentValue

    property alias label: labelItem.text
    property alias validationError: validationErrorItem.text

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    LayoutMirroring.childrenInherit: true

    ColumnLayout {
        id: layout

        anchors.fill: parent
        spacing: 0

        StatusBaseText {
            id: labelItem
            Layout.fillWidth: true
            visible: !!text
            font.pixelSize: 15
            color: root.enabled ? Theme.palette.directColor1 : Theme.palette.baseColor1
        }

        ComboBox {
            id: comboBox

            property color bgColor: Theme.palette.baseColor2
            property color bgColorHover: bgColor

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: labelItem.visible ? 7 : 0

            enabled: root.enabled

            font.family: Theme.palette.baseFont.name
            font.pixelSize: 14

            padding: 16
            spacing: 16

            background: Rectangle {
                implicitHeight: 56
                implicitWidth: 448
                color: Theme.palette.baseColor2
                radius: 8
                border.width: !!root.validationError || comboBox.hovered || comboBox.down || comboBox.activeFocus ? 1 : 0
                border.color: !!root.validationError
                              ? Theme.palette.dangerColor1
                              : comboBox.activeFocus
                                ? Theme.palette.primaryColor1
                                : comboBox.hovered
                                  ? Theme.palette.primaryColor2
                                  : "transparent"
            }

            contentItem: StatusBaseText {
                font: comboBox.font
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                text: comboBox.displayText
                color: root.enabled ? Theme.palette.directColor1 : Theme.palette.baseColor1
            }

            indicator: StatusIcon {
                x: comboBox.mirrored ? comboBox.padding : comboBox.width - width - comboBox.padding
                y: comboBox.topPadding + (comboBox.availableHeight - height) / 2
                width: 24
                height: 24
                icon: "chevron-down"
                color: Theme.palette.baseColor1
            }

            popup: Popup {
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                y: comboBox.height + 8

                width: comboBox.width
                height: Math.min(implicitContentHeight + topPadding + bottomPadding,
                                 comboBox.Window.height - topMargin - bottomMargin)
                margins: 8

                padding: 1
                verticalPadding: 8

                background: Rectangle {
                    id: backgroundItem
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

                contentItem: StatusListView {
                    id: listView

                    implicitWidth: contentWidth
                    implicitHeight: contentHeight

                    model: comboBox.popup.visible ? comboBox.delegateModel : null
                    currentIndex: comboBox.highlightedIndex
                }
            }

            delegate: StatusItemDelegate {
                width: comboBox.width
                highlighted: comboBox.highlightedIndex === index
                font: comboBox.font
                text: control.textRole ? (Array.isArray(control.model)
                                          ? modelData[control.textRole]
                                          : model[control.textRole])
                                       : modelData
            }
        }


        StatusBaseText {
            id: validationErrorItem
            Layout.fillWidth: true
            Layout.topMargin: 11
            visible: !!text
            font.pixelSize: 12
            color: Theme.palette.dangerColor1
            horizontalAlignment: TextEdit.AlignRight
            wrapMode: Text.WordWrap
        }
    }
}
