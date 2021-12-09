import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared 1.0
import shared.popups 1.0

import "./"
import "../panels"

// TODO: replace with StatusModal
ModalPopup {
    id: root
    //% "Dapp permissions"
    title: qsTrId("dapp-permissions")

    property var store

    Component.onCompleted: store.initDappList()

    property Component permissionListPopup: PermissionList {
        onClosed: destroy()
        store: root.store
        onAccessRevoked: store.initDappList()
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
                model: root.store.dappList
                delegate: Dapp {
                  name: model.name
                  onDappClicked: Global.openPopup(permissionListPopup, {dapp: dapp})
                }
            }
        }
    }
}
