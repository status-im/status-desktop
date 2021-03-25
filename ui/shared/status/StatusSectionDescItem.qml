import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../../imports"
import "../../shared"

Item {
    property string name
    property string description
    property alias tooltipUnder: copyToClipboardBtn.tooltipUnder

    id: root
    width: parent.width
    height: name.height

    StyledText {
        id: name
        text: root.name
        font.pixelSize: 15
    }

    StyledText {
        id: description
        visible: !!root.description
        text: root.description
        elide: Text.ElideRight
        font.pixelSize: 15
        horizontalAlignment: Text.AlignRight
        color: Style.current.secondaryText
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
        anchors.verticalCenter: name.verticalCenter

        CopyToClipBoardButton {
            id: copyToClipboardBtn
            textToCopy: root.description
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.right
            anchors.leftMargin: Style.current.smallPadding
        }
    }
}

