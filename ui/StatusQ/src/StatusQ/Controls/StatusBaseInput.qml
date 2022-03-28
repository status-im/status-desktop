import QtQuick 2.14

import QtQuick.Controls 2.14 as QC
import QtQuick.Layouts 1.14

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Item {
    id: root

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
    property alias background: background

    property alias color: edit.color
    property alias font: edit.font
    property alias focussed: edit.activeFocus
    property alias verticalAlignmet: edit.verticalAlignment
    property alias horizontalAlignment: edit.horizontalAlignment

    property alias placeholderText: placeholder.text
    property alias placeholderTextColor: placeholder.color
    property alias placeholderFont: placeholder.font

    property real leftPadding: leftComponentLoader.item ? 8 : 16
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
    property bool showBackground: true

    property StatusIconSettings icon: StatusIconSettings {
        width: 24
        height: 24
        name: ""
        color: Theme.palette.baseColor1
        emoji: ""
        letterSize: emoji ? 11 : 14
        background: StatusIconBackgroundSettings {
            width: 30
            height: 30
            color: Theme.palette.indirectColor1
        }
    }

    property Component leftComponent
    property Component rightComponent

    signal iconClicked

    implicitWidth: 448
    implicitHeight: multiline ? Math.min(Math.max(
                                    (edit.implicitHeight + topPadding + bottomPadding),
                                    44, root.minimumHeight), root.maximumHeight) : 44

    Rectangle {
        id: background
        width: parent.width
        height: maximumHeight != 0 ? Math.min(
                                         minimumHeight
                                         != 0 ? Math.max(
                                                    root.implicitHeight,
                                                    minimumHeight) : root.implicitHeight,
                                         maximumHeight) : parent.height
        color: root.showBackground ? Theme.palette.baseColor2
                                              : "transparent"
        radius: 8

        clip: true

        border.width: 1
        border.color: {
            if (!root.showBackground) {
                return "transparent"
            }
            if (!root.valid && root.dirty) {
                return Theme.palette.dangerColor1
            }
            if (edit.activeFocus) {
                return Theme.palette.primaryColor1
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

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: root.leftPadding
                    rightMargin: root.rightPadding
                }

                clip: true

                Loader {
                    id: leftComponentLoader
                    sourceComponent: {
                        if (root.leftComponent) return root.leftComponent
                        if (!root.leftIcon) return undefined
                        if (root.icon.emoji) return identiconComponent
                        if (root.icon.name) return isIconSelectable ? identiconComponent : iconComponent
                        return undefined
                    }
                }

                Flickable {
                    id: flick

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.topMargin: root.topPadding
                    Layout.bottomMargin: root.bottomPadding

                    contentWidth: edit.paintedWidth
                    contentHeight: edit.paintedHeight
                    boundsBehavior: Flickable.StopAtBounds
                    QC.ScrollBar.vertical: QC.ScrollBar {
                        interactive: multiline
                        enabled: multiline
                    }
                    clip: true

                    function ensureVisible(r) {
                        if (contentX >= r.x)
                            contentX = r.x
                        else if (contentX + width <= r.x + r.width)
                            contentX = r.x + r.width - width
                        if (contentY >= r.y)
                            contentY = r.y
                        else if (contentY + height <= r.y + r.height)
                            contentY = r.y + r.height - height
                    }

                    TextEdit {
                        id: edit

                        property string previousText: text
                        property var keyEvent

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
                        wrapMode: root.multiline ? Text.WrapAtWordBoundaryOrAnywhere : TextEdit.NoWrap

                        Keys.onReturnPressed: event.accepted = !multiline
                        Keys.onEnterPressed: event.accepted = !multiline
                        Keys.forwardTo: [root]
                        Keys.onPressed: edit.keyEvent = event.key

                        onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)
                        onActiveFocusChanged: if (root.pristine) root.pristine = false
                        onTextChanged: {
                            root.dirty = true
                            if (root.maximumLength > 0) {
                                if (text.length > root.maximumLength) {
                                    var cursor = cursorPosition
                                    text = previousText
                                    if (cursor > text.length) {
                                        cursorPosition = text.length
                                    } else {
                                        cursorPosition = cursor - 1
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
                            anchors.rightMargin: root.rightPadding
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 15
                            elide: StatusBaseText.ElideRight
                            font.family: Theme.palette.baseFont.name
                            color: root.enabled ? Theme.palette.baseColor1 : Theme.palette.directColor6
                        }
                    }
                } // Flickable

                Loader {
                    sourceComponent: {
                        if (root.rightComponent) return root.rightComponent
                        if (root.clearable) return clearButton
                        if (root.leftIcon) return undefined
                        if (root.icon.emoji) return identiconComponent
                        if (root.icon.name) return isIconSelectable ? identiconComponent : iconComponent
                        return undefined
                    }
                }
            }
        }
    } // Rectangle


    Component {
        id: clearButton

        StatusFlatRoundButton {
            visible: edit.text.length != 0 && root.clearable && !root.multiline
                     && edit.activeFocus
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

    Component {
        id: identiconComponent

        StatusSmartIdenticon {
            id: identicon

            icon.width: !root.icon.emoji ? 20 : 30
            icon.height: !root.icon.emoji ? 20 : 30
            icon.background: root.icon.background
            icon.color: root.icon.color
            icon.letterSize: root.icon.letterSize
            icon.emoji: root.icon.emoji
            icon.name: !root.icon.emoji ? root.icon.name : ""

            MouseArea {
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                anchors.fill: parent
                hoverEnabled: true
                enabled: identicon.visible
                onClicked: root.iconClicked()
            }
        }
    }

    Component {
        id: iconComponent

        StatusIcon {
            id: statusIcon

            icon: root.icon.name
            width: root.icon.width
            height: root.icon.height
            color: root.icon.color
        }
    }
}
