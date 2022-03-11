import QtQuick 2.14

import QtQuick.Controls 2.14 as QC

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1


Item {
    id: statusBaseInput

    property bool multiline: false

    property bool clearable: false

    property alias inputMethodHints: edit.inputMethodHints

    property alias selectedText: edit.selectedText
    property alias selectedTextColor: edit.selectedTextColor
    property alias selectionStart: edit.selectionStart
    property alias selectionEnd: edit.selectionEnd
    property alias cursorPosition: edit.cursorPosition

    property alias edit: edit
    property alias text: edit.text

    property alias color: edit.color
    property alias font: edit.font
    property alias focussed: edit.activeFocus
    property alias verticalAlignmet: edit.verticalAlignment
    property alias horizontalAlignment: edit.horizontalAlignment

    property alias placeholderText: placeholder.text
    property alias placeholderTextColor: placeholder.color
    property alias placeholderFont: placeholder.font

    property real leftPadding: 16
    property real rightPadding: 16
    property real topPadding: 12
    property real bottomPadding: 12

    property real minimumHeight: 0
    property real maximumHeight: 0
    property int maximumLength: 0

    property bool valid: true
    property bool pristine: true
    property bool dirty: false
    property bool pending: false
    property bool leftIcon: true
    property bool isIconSelectable: false

    property StatusIconSettings icon: StatusIconSettings {
        width: 24
        height: 24
        name: ""
        color: Theme.palette.baseColor1
        emoji: ""
        letterSize: 14
        background: StatusIconBackgroundSettings {
            width: 30
            height: 30
            color: Theme.palette.indirectColor1
        }
    }

    property Item component

    signal iconClicked()

    onClearableChanged: {
        if (clearable && !component) {
            clearButtonLoader.active = true
            clearButtonLoader.parent = statusBaseInputComponentSlot
        } else {
            clearButtonLoader.active = false
        }
    }

    onComponentChanged: {
        if (!!component) {
            component.parent = statusBaseInputComponentSlot
        }
    }

    implicitWidth: 448
    implicitHeight: multiline ? Math.max((edit.implicitHeight + topPadding + bottomPadding), 44) : 44

    Rectangle {
        width: parent.width
        height: maximumHeight != 0 ? Math.min(
                                         minimumHeight != 0 ? Math.max(statusBaseInput.implicitHeight, minimumHeight)
                                         : statusBaseInput.implicitHeight, maximumHeight) : parent.height
        color: Theme.palette.baseColor2
        radius: 8

        clip: true

        border.width: 1
        border.color: {
            if (!statusBaseInput.valid && statusBaseInput.dirty) {
                return Theme.palette.dangerColor1;
            }
            if (edit.activeFocus) {
                return Theme.palette.primaryColor1;
            }
            return sensor.containsMouse ? Theme.palette.primaryColor2 : "transparent"
        }


        MouseArea {
            id: sensor
            enabled: !edit.activeFocus
            hoverEnabled: true
            anchors.fill: parent
            cursorShape: Qt.IBeamCursor
            onClicked: {
                edit.forceActiveFocus()
            }

            StatusSmartIdenticon {
                id: emoji
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                icon.width: !statusBaseInput.icon.emoji ? 20 : 30
                icon.height: !statusBaseInput.icon.emoji ? 20 : 30
                icon.background: statusBaseInput.icon.background
                icon.color: statusBaseInput.icon.color
                icon.letterSize: statusBaseInput.icon.letterSize
                icon.emoji: statusBaseInput.icon.emoji
                icon.name: !statusBaseInput.icon.emoji ? statusBaseInput.icon.name : ""
                visible: (!!statusBaseInput.icon.emoji || !!statusBaseInput.icon.name) && statusBaseInput.isIconSelectable
                MouseArea {
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: emoji.visible
                    onClicked: statusBaseInput.iconClicked()
                }
            }

            StatusIcon {
                id: statusIcon
                anchors.topMargin: 10
                anchors.left: statusBaseInput.leftIcon ? parent.left : undefined
                anchors.right: !statusBaseInput.leftIcon ? parent.right : undefined
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                icon: statusBaseInput.icon.name
                width: statusBaseInput.icon.width
                height: statusBaseInput.icon.height
                color: statusBaseInput.icon.color
                visible: !!statusBaseInput.icon.name && !statusBaseInput.isIconSelectable
            }

            Flickable {
                id: flick
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: (statusIcon.visible && statusBaseInput.leftIcon) ?
                              statusIcon.right : emoji.visible ? emoji.right: parent.left
                anchors.right: {
                    if (!!statusBaseInput.component) {
                        return statusBaseInputComponentSlot.left
                    }
                    return statusIcon.visible && !statusBaseInput.leftIcon ? statusIcon.left : parent.right
                }
                anchors.leftMargin: statusIcon.visible && statusBaseInput.leftIcon ? 8
                                    : statusBaseInput.leftPadding
                anchors.rightMargin: {
                    return clearable ? clearButtonLoader.width + 12 : 
                        (statusIcon.visible && !leftIcon) || !!statusBaseInput.component ? 8 : 0
                }
                contentWidth: edit.paintedWidth
                contentHeight: edit.paintedHeight
                boundsBehavior: Flickable.StopAtBounds
                QC.ScrollBar.vertical: QC.ScrollBar { interactive: multiline; enabled: multiline }
                clip: true
                function ensureVisible(r) {
                    if (contentX >= r.x)
                        contentX = r.x;
                    else if (contentX+width <= r.x+r.width)
                        contentX = r.x+r.width-width;
                    if (contentY >= r.y)
                        contentY = r.y;
                    else if (contentY+height <= r.y+r.height)
                        contentY = r.y+r.height-height;
                }
                TextEdit {
                    id: edit
                    property string previousText: text
                    width: flick.width
                    height: flick.height
                    verticalAlignment: Text.AlignVCenter
                    selectByMouse: true
                    selectionColor: Theme.palette.primaryColor2
                    selectedTextColor: color
                    focus: true
                    font.pixelSize: 15
                    font.family: Theme.palette.baseFont.name
                    color: Theme.palette.directColor1
                    onCursorRectangleChanged: { flick.ensureVisible(cursorRectangle); }
                    wrapMode: statusBaseInput.multiline ? Text.WrapAtWordBoundaryOrAnywhere : TextEdit.NoWrap
                    onActiveFocusChanged: {
                        if (statusBaseInput.pristine) {
                            statusBaseInput.pristine = false
                        }
                    }

                    Keys.onReturnPressed: {
                        if (multiline) {
                            event.accepted = false
                        } else {
                            event.accepted = true
                        }
                    }

                    Keys.onEnterPressed: {
                        if (multiline) {
                            event.accepted = false
                        } else {
                            event.accepted = true
                        }
                    }

                    Keys.forwardTo: [statusBaseInput]

                    onTextChanged: {
                        statusBaseInput.dirty = true
                        if (statusBaseInput.maximumLength > 0) {
                            if (text.length > statusBaseInput.maximumLength) {
                                var cursor = cursorPosition;
                                text = previousText;
                                if (cursor > text.length) {
                                    cursorPosition = text.length;
                                } else {
                                    cursorPosition = cursor-1;
                                }
                            }
                            previousText = text
                        }
                    }
                    StatusBaseText {
                        id: placeholder
                        visible: (edit.text.length === 0)
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: statusBaseInput.rightPadding
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 15
                        elide: StatusBaseText.ElideRight
                        font.family: Theme.palette.baseFont.name
                        color: statusBaseInput.enabled ? Theme.palette.baseColor1 :
                                                        Theme.palette.directColor6
                    }
                }

            } // Flickable

            Item {
                id: statusBaseInputComponentSlot
                anchors.right: parent.right
                anchors.rightMargin: 12
                width: childrenRect.width
                height: childrenRect.height
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    } // Rectangle

    Loader {
        id: clearButtonLoader
        sourceComponent: StatusFlatRoundButton {
            id: clearButton
            visible: edit.text.length != 0 &&
                    statusBaseInput.clearable &&
                    !statusBaseInput.multiline &&
                    edit.activeFocus
            type: StatusFlatRoundButton.Type.Secondary
            width: 24
            height: 24
            icon.name: "clear"
            icon.width: 16
            icon.height: 16
            icon.color: Theme.palette.baseColor1
            onClicked: {
                edit.clear()
            }
        }
    }


}
