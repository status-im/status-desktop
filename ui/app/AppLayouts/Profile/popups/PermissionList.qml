import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Controls 0.1

import shared.popups 1.0

import utils 1.0

import "../panels"

// TODO: replace with StatusModal
ModalPopup {
    property string dapp: ""

    id: root
    title: dapp

    width: 400
    height: 400

    property var store

    Component.onCompleted: store.initPermissionList(dapp)

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
                model: root.store.permissionList
                delegate: Permission {
                  name: model.name
                  onRemoveBtnClicked: {
                      root.store.revokePermission(dapp, model.name);
                      if(permissionListView.count === 1){
                            accessRevoked(dapp);
                            close();
                      }
                      root.store.initPermissionList(dapp)
                  }
                }
            }
        }
    }
    
    footer: StatusButton {
        anchors.horizontalCenter: parent.horizontalCenter
        type: StatusBaseButton.Type.Danger
        //% "Revoke all access"
        text: qsTrId("revoke-all-access")
        onClicked: {
            root.store.clearPermissions(dapp)
            accessRevoked(dapp);
            close();
        }
    }
}
