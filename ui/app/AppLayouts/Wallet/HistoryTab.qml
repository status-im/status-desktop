import QtQuick 2.13
import "./Components"
import "../../../imports"

Item {
    Component {
      id: transactionListItemCmp

      Rectangle {
        id: transactionListItem
        property bool isHovered: false
        anchors.right: parent.right
        anchors.left: parent.left
        height: 64
        color: isHovered ? "#f0f0f0" : "white"

        MouseArea {
            anchors.fill: parent
            onClicked: transactionModal.open()
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onEntered: {
              transactionListItem.isHovered = true
            }
            onExited: {
              transactionListItem.isHovered = false
            }
        }


        TransactionModal{
          id: transactionModal
        }

        Item {

          Rectangle {
            id: assetIcon
            color: "gray"
            width: 40
            height: 40
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 12
            radius: 50
          }

          Text {
            id: transferIcon
            anchors.topMargin: 25
            anchors.top: parent.top
            anchors.left: assetIcon.right
            anchors.leftMargin: 22
            height: 15
            width: 15
            color: to != walletModel.currentAccount.address ? "#4360DF" : "green"
            text: to != walletModel.currentAccount.address ? "↑" : "↓"
          }

          Text {
            id: transactionValue
            anchors.left: transferIcon.right
            anchors.leftMargin: Theme.smallPadding
            anchors.top: parent.top
            anchors.topMargin: Theme.bigPadding
            font.pixelSize: 15
            text: value + " TOKEN"
          }
        }

        Item {
          anchors.right: timeInfo.left
          anchors.top: parent.top
          anchors.topMargin: Theme.bigPadding
          width: children[0].width + children[1].width

          Text {
              text: to != walletModel.currentAccount.address ? "To " : "From "
              anchors.right: addressValue.left
              color: Theme.darkGrey
              anchors.top: parent.top
              font.pixelSize: 15
              font.strikeout: false
          }

          Text {
              id: addressValue
              text: to
              width: 100
              elide: Text.ElideMiddle
              anchors.right: parent.right
              anchors.top: parent.top
              font.pixelSize: 15
          }
        }

        Item {
          id: timeInfo
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.topMargin: Theme.bigPadding
          width: children[0].width + children[1].width + children[2].width

          Text {
              text: "• "
              font.weight: Font.Bold
              anchors.right: timeIndicator.left
              color: Theme.darkGrey
              anchors.top: parent.top
              font.pixelSize: 15
          }

          Text {
              id: timeIndicator
              text: "At "
              anchors.right: timeValue.left
              color: Theme.darkGrey
              anchors.top: parent.top
              font.pixelSize: 15
              font.strikeout: false
          }

          Text {
              id: timeValue
              text: timestamp
              anchors.right: parent.right
              anchors.top: parent.top
              font.pixelSize: 15
          }
        }
      }
    }

    ListView {
      anchors.topMargin: 20
      anchors.fill: parent
      model: walletModel.transactions
      delegate: transactionListItemCmp
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
