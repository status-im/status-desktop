import QtQuick 2.14
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

/*!
     \qmltype StatusTagItem
     \inherits Control
     \inqmlmodule StatusQ.Controls
     \since StatusQ.Controls 0.1
     \brief Represents a tag item.
     Inherits \l{https://doc.qt.io/qt-5/qml-qtquick-controls2-control.html}{Control}.

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
Control {
    id: root

    /*!
    \qmlproperty bool StatusTagItem::isReadonly
    This property sets if the tag is readonly or not.
*/
    property bool isReadonly
    /*!
    \qmlproperty string StatusTagItem::text
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
    This signal is emitted when the close button is clicked.
*/
    signal closed()

    QtObject {
        id: d
        readonly property int tagMargins: 8
        readonly property int tagIconsSize: 20

        function getTagColor(isReadonly) {
            if(isReadonly)
                return Theme.palette.baseColor1
            return mouseArea.containsMouse ? Theme.palette.miscColor1 : Theme.palette.primaryColor1
        }
    }

    implicitHeight: 30
    horizontalPadding: d.tagMargins
    font.pixelSize: 15
    font.family: Theme.palette.baseFont.name

    background: Rectangle {
        color: d.getTagColor(root.isReadonly)
        radius: 8
    }

    contentItem: RowLayout {
        id: tagRow
        spacing: 2

        StatusIcon {
            visible: root.icon
            color: Theme.palette.indirectColor1
            width: root.icon ? d.tagIconsSize : 0
            height: d.tagIconsSize
            icon: root.icon
        }
        StatusBaseText {
            color: Theme.palette.indirectColor1
            font: root.font
            text: root.text
        }
        StatusIcon {
            Layout.leftMargin: d.tagMargins
            visible: !root.isReadonly
            color: Theme.palette.indirectColor1
            width: d.tagIconsSize
            height: d.tagIconsSize
            icon: "close"
            MouseArea {
                id: mouseArea
                enabled: !root.isReadonly
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: { root.closed() }
            }
        }
    }
}
