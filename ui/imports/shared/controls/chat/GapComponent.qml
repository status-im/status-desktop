import QtQuick 2.13
import shared 1.0
import shared.panels 1.0
import shared.stores 1.0
import utils 1.0

Item {
    id: root

    property int gapFrom: 0
    property int gapTo: 0

    signal clicked()

    height: childrenRect.height + Style.current.smallPadding * 2
    anchors.left: parent.left
    anchors.right: parent.right

    Separator {
        id: sep1
    }
    StyledText {
        id: fetchMoreButton
        font.weight: Font.Medium
        font.pixelSize: Style.current.primaryTextFontSize
        color: Style.current.blue
        text: qsTr("Fetch messages")
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: sep1.bottom
        anchors.topMargin: Style.current.smallPadding
        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked: {
                root.clicked();
            }
        }
    }
    StyledText {
        id: fetchDate
        anchors.top: fetchMoreButton.bottom
        anchors.topMargin: 3
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        color: Style.current.secondaryText
        text: qsTr("Between %1 and %2").arg(Utils.formatLongDate(root.gapFrom * 1000, RootStore.accountSensitiveSettings.isDDMMYYDateFormat))
            .arg(Utils.formatLongDate(root.gapTo * 1000, RootStore.accountSensitiveSettings.isDDMMYYDateFormat))
    }
    Separator {
        anchors.top: fetchDate.bottom
        anchors.topMargin: Style.current.smallPadding
    }
}
