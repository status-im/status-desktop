import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

/*!
     \qmltype StatusTagItem
     \inherits Item
     \inqmlmodule StatusQ.Controls
     \since StatusQ.Controls 0.1
     \brief Reprsents a tag item.
     Inherits \l{https://doc.qt.io/qt-5/qml-qtquick-rectangle.html}{Item}.

     The \c StatusTagItem represents a tag item where a name and icon can be displayed and can be clicked.
     Example:

     \qml
        StatusTagItem {
            isReadonly: model.isReadonly
            text: model.name
            icon: model.tagIcon

            onClicked: { console.log("Tag selected!") }
        }
     \endqml

     For a list of components available see StatusQ.
  */
Rectangle {
    id: root

    /*!
        \qmlproperty bool StatusTagItem::isReadonly
        This property sets if the tag is readonly or not.
    */
    property bool isReadonly
    /*!
        \qmlproperty string StatusTagItem::name
        This property sets the tag text to display.
    */
    property string text
    /*!
        \qmlproperty string StatusTagItem::icon
        This property sets the tag icon to display.
    */
    property string icon

    /*!
        \qmlsignal
        This signal is emitted when the tag is clicked.
    */
    signal clicked()

    QtObject {
        id: d
        property int tagMargins: 8
        property int tagIconsSize: 20

        function getTagColor(isReadonly) {
            if(isReadonly) {
                return Theme.palette.baseColor1
            }
            else {
                return mouseArea.containsMouse ? Theme.palette.miscColor1 : Theme.palette.primaryColor1
            }
        }
    }

    width: tagRow.implicitWidth + 2 * d.tagMargins
    height: 30
    color: d.getTagColor(root.isReadonly)
    radius: 8
    Row {
        id: tagRow
        height: parent.height
        anchors.left: parent.left
        anchors.leftMargin: d.tagMargins
        anchors.rightMargin: d.tagMargins
        spacing: 2

        StatusIcon {
            visible: root.icon
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.palette.indirectColor1
            width: root.icon ? d.tagIconsSize : 0
            height: d.tagIconsSize
            icon: root.icon
        }
        StatusBaseText {
            id: nameText
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.palette.indirectColor1
            font.pixelSize: 15
            text: root.text
        }
        StatusIcon {
            id: closeIcon
            visible: !root.isReadonly
            anchors.leftMargin: d.tagMargins
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.palette.indirectColor1
            width: d.tagIconsSize
            height: d.tagIconsSize
            icon: "close"
        }
    }

    MouseArea {
        id: mouseArea
        enabled: !root.isReadonly
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: { root.clicked() }
    }
}
