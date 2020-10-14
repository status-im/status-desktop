import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import "../../../../imports"
import "../../../../shared"
import "./"

ModalPopup {
    id: popup
    height: 504

    property string txHash: ""
    property string channelname: ""

    title: qsTr("Transaction sent")

    StyledText {
        id: text1
        text: qsTr("Transaction successfully sent. You can watch the progress by clicking the button below")
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        wrapMode: "WordWrap"
    }

    StyledButton {
        id: btn1
        label: qsTr("Go to block explorer")
        anchors.top: text1.bottom
        anchors.topMargin: Style.current.smallPadding
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: Qt.openUrlExternally(`https://blockscout.com/poa/xdai/tx/${popup.txHash}/internal-transactions`)
    }

    StyledText {
        id: text2
        text: qsTr("Once the transaction is done, you can open the channel")
        anchors.top: btn1.bottom
        anchors.topMargin: Style.current.padding
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        wrapMode: "WordWrap"
    }

    StyledButton {
        label: qsTr("Go to channel")
        anchors.top: text2.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Style.current.smallPadding
        onClicked: {
            chatsModel.joinChat(popup.channelname, Constants.chatTypePublic);
            popup.close();
        }
    }
}

