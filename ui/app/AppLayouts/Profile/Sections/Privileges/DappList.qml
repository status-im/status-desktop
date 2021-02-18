import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../../imports"
import "../../../../../shared"
import "./"

ModalPopup {
    id: popup
    //% "Dapp permissions"
    title: qsTrId("dapp-permissions")

    Component.onCompleted: profileModel.dappList.init()
    Component.onDestruction: profileModel.dappList.clearData()

    property Component permissionListPopup: PermissionList {
        onClosed: destroy()
        onAccessRevoked: profileModel.dappList.init()
    }

    Item {
        anchors.fill: parent

        ScrollView {
            anchors.fill: parent
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: dappListView.contentHeight > dappListView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

            ListView {
                anchors.fill: parent
                spacing: 0
                clip: true
                id: dappListView
                model: profileModel.dappList
                delegate: Dapp {
                  name: model.name
                  onDappClicked: permissionListPopup.createObject(privacyContainer, {dapp: dapp}).open()
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;height:300;width:300}
}
##^##*/
