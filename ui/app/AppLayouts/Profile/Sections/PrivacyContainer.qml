import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"

Item {
    id: privacyContainer
    width: 200
    height: 200
    Layout.fillHeight: true
    Layout.fillWidth: true

    StyledText {
        id: element3
        text: qsTr("Privacy and security settings")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    Text {
      id: labelSecurity
      text: qsTr("Security")
      font.pixelSize: 13
      font.weight: Font.Medium
      color: Style.current.darkGrey
      anchors.left: parent.left
      anchors.leftMargin: Style.current.bigPadding
      anchors.top: element3.bottom
      anchors.topMargin: Style.current.smallPadding
    }

    Item {
      anchors.top: labelSecurity.bottom
      anchors.topMargin: Style.current.padding
      anchors.left: parent.left
      anchors.leftMargin: Style.current.bigPadding
      height: children[0].height
      width: children[0].width
      Text {
          text: qsTr("Backup Seed Phrase")
          font.pixelSize: 14
      }
      MouseArea {
          anchors.fill: parent
          onClicked: backupSeedModal.open()
          cursorShape: Qt.PointingHandCursor
      }
    }

    BackupSeedModal{
        id: backupSeedModal
    }
}
