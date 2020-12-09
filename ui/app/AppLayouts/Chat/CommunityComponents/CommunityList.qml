import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../shared"
import "../../../../imports"
import "../components"
import "./"

Item {
    property string searchStr: ""
    id: root
    width: parent.width
    height: childrenRect.height
    visible: communityListView.visible

    ListView {
        id: communityListView
        spacing: Style.current.halfPadding
        anchors.top: parent.top
        height: childrenRect.height
        // FIXME the height doesn't update
//        visible: height > 0
        width:parent.width
        interactive: false
        model: chatsModel.joinedCommunities
        delegate: CommunityButton {
            communityId: model.id
            name: model.name
            description: model.description
            // TODO add other properties
            searchStr: root.searchStr
        }
    }

    Item {
        id: noSearchResults
        anchors.top: parent.top
        height: visible ? 200 : 0
        visible: !communityListView.visible && root.searchStr !== ""
        width: parent.width

        StyledText {
            font.pixelSize: 15
            color: Style.current.darkGrey
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("No search results in Communities")
        }
    }

//    Connections {
//        target: chatsModel.chats
//        onDataChanged: {
//            // If the current active channel receives messages and changes its position,
//            // refresh the currentIndex accordingly
//            if(chatsModel.activeChannelIndex !== communityListView.currentIndex){
//                communityListView.currentIndex = chatsModel.activeChannelIndex
//            }
//        }
//    }

//    Connections {
//        target: chatsModel
//        onActiveChannelChanged: {
//            chatsModel.hideLoadingIndicator()
//            communityListView.currentIndex = chatsModel.activeChannelIndex
//            SelectedMessage.reset();
//            chatColumn.isReply = false;
//        }
//    }
}


/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
