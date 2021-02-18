import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../../imports"
import "../../../../../shared"
import "../../../../../shared/status"
import "./"

ModalPopup {
    property string dapp: ""

    id: popup
    title: dapp

    width: 400
    height: 400

    Component.onCompleted: profileModel.dappList.permissionList.init(dapp)
    Component.onDestruction: profileModel.dappList.permissionList.clearData()

    signal accessRevoked(string dapp)

    Item {
        anchors.fill: parent

        ScrollView {
            anchors.fill: parent
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: permissionListView.contentHeight > permissionListView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

            ListView {
                anchors.fill: parent
                spacing: 0
                clip: true
                id: permissionListView
                model: profileModel.dappList.permissionList
                delegate: Permission {
                  name: model.name
                  onRemoveBtnClicked: {
                      profileModel.dappList.permissionList.revokePermission(model.name);
                      if(permissionListView.count === 1){
                            accessRevoked(dapp);
                            close();
                      }
                      profileModel.dappList.permissionList.init(dapp)
                  }
                }
            }
        }
    }
    
    footer: StatusButton {
        anchors.horizontalCenter: parent.horizontalCenter
        type: "warn"
        //% "Revoke all access"
        text: qsTrId("revoke-all-access")
        onClicked: {
            profileModel.dappList.permissionList.revokeAccess();
            accessRevoked(dapp);
            close();
        }
    }
}

/*##^##
Designer {
    D{i:0;height:300;width:300}
}
##^##*/
