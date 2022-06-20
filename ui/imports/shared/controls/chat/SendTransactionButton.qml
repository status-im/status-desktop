import QtQuick 2.3

import utils 1.0
import shared 1.0
import shared.panels 1.0

Item {
    id: root
    width: parent.width
    height: childrenRect.height + Style.current.halfPadding

    property var acc
    property string fromAddress
    property var selectedRecipient
    property var selectedAsset
    property string selectedAmount
    property string selectedFiatAmount

    signal sendTransaction()

    Separator {
        id: separator
    }

    StyledText {
        id: signText
        color: Style.current.blue
        //% "Sign and send"
        text: qsTrId("sign-and-send")
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.weight: Font.Medium
        anchors.right: parent.right
        anchors.left: parent.left
        topPadding: Style.current.halfPadding
        anchors.top: separator.bottom
        font.pixelSize: Style.current.primaryTextFontSize

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.sendTransaction();
            }
        }
    }
}
