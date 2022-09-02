import QtQuick 2.14

import QtQuick.Controls 2.14 as QC

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1


Item {
    id: statusSelectableText

    property bool multiline: false
    property string text: ""
    property string hoveredLinkColor: Theme.palette.directColor1

    property alias selectedText: edit.selectedText
    property alias selectedTextColor: edit.selectedTextColor
    property alias selectionStart: edit.selectionStart
    property alias selectionEnd: edit.selectionEnd
    property alias cursorPosition: edit.cursorPosition
    property alias hoveredLink: edit.hoveredLink
    property alias color: edit.color
    property alias font: edit.font
    property alias focussed: edit.activeFocus
    property alias verticalAlignment: edit.verticalAlignment
    property alias horizontalAlignment: edit.horizontalAlignment

    signal linkActivated(string link)

    implicitWidth: multiline ? 0 :  edit.implicitWidth
    implicitHeight: edit.implicitHeight

    clip:true

    MouseArea {
        id: sensor
        enabled: !edit.activeFocus
        hoverEnabled: true
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        onClicked: {
            edit.forceActiveFocus()
        }
        onExited: {
            flick.contentX = 0
            flick.contentY = 0
        }

        Flickable {
            id: flick
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left:  parent.left
            anchors.right: parent.right
            contentWidth: edit.paintedWidth
            contentHeight: edit.paintedHeight
            boundsBehavior: Flickable.StopAtBounds
            QC.ScrollBar.vertical: QC.ScrollBar { interactive: multiline; enabled: multiline }

            TextEdit {
                id: edit
                width: flick.width
                height: flick.height
                verticalAlignment: Text.AlignVCenter
                readOnly: true
                selectByMouse: true
                selectionColor: Theme.palette.primaryColor2
                selectedTextColor: color
                focus: true
                font.pixelSize: 15
                font.family: Theme.palette.baseFont.name
                color: Theme.palette.directColor1
                textFormat: Text.RichText
                onCursorRectangleChanged: Utils.ensureVisible(flick, cursorRectangle)
                wrapMode: statusSelectableText.multiline ? Text.WrapAtWordBoundaryOrAnywhere : TextEdit.NoWrap

                Keys.forwardTo: [statusSelectableText]

                onFocusChanged: {
                    if(!focus) {
                        flick.contentX = 0
                        flick.contentY = 0
                    }
                }

                onLinkActivated: statusSelectableText.linkActivated(link)

                text: "<style>a:link { color: " + (!!hoveredLink ? statusSelectableText.hoveredLinkColor : Theme.palette.baseColor1) + "; }</style>" + statusSelectableText.text
            }

        }
    }
}
