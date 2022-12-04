import QtQuick 2.14
import QtQuick.Controls 2.14

import shared.controls 1.0

import StubDecorators 1.0

Pane {
    SharedRootStoreDecorator {}
    UtilsDecorator { id: utilsDecorator }

    ContactsListAndSearch {
        //inject mainModule (expected as context property)
        property var mainModule: utilsDecorator.mainModule
        anchors.fill: parent

        community: ({ id: "communityId" })

        contactsStore: QtObject {
            readonly property ListModel myContactsModel: ListModel {
                ListElement {
                    pubKey: "0x02342342342"
                    isContact: true
                    onlineStatus: true
                    displayName: "x1"
                    icon: ""
                    colorId: 0
                    ensName: "ens name"
                    isBlocked: false
                    alias: "some alias"
                    localNickname: "l1"
                }
                ListElement {
                    pubKey: "0x02342342342"
                    isContact: true
                    onlineStatus: true
                    displayName: "x2 sdfsd"
                    icon: ""
                    colorId: 0
                    ensName: "ens name"
                    isBlocked: false
                    alias: "some alias"
                    localNickname: ""
                }
                ListElement {
                    pubKey: "0x02342342342"
                    isContact: true
                    onlineStatus: true
                    displayName: "x3 xcvxcv"
                    icon: ""
                    colorId: 0
                    ensName: "ens name"
                    isBlocked: false
                    alias: "some alias"
                    localNickname: ""
                }
                ListElement {
                    pubKey: "0x02342342342"
                    isContact: true
                    onlineStatus: true
                    displayName: "x4 drt5"
                    icon: ""
                    colorId: 0
                    ensName: "ens name"
                    isBlocked: false
                    alias: "some alias"
                    localNickname: ""
                }
                ListElement {
                    pubKey: "0x02342342342"
                    isContact: true
                    onlineStatus: true
                    displayName: "x4 drt5e"
                    icon: ""
                    colorId: 0
                    ensName: "ens name"
                    isBlocked: false
                    alias: "some alias"
                    localNickname: ""
                }
                ListElement {
                    pubKey: "0x02342342342"
                    isContact: true
                    onlineStatus: true
                    displayName: "x4 drtew5"
                    icon: ""
                    colorId: 0
                    ensName: "ens name"
                    isBlocked: false
                    alias: "some alias"
                    localNickname: ""
                }
                ListElement {
                    pubKey: "0x02342342342"
                    isContact: true
                    onlineStatus: true
                    displayName: "x4 drt5e"
                    icon: ""
                    colorId: 0
                    ensName: "ens name"
                    isBlocked: false
                    alias: "some alias"
                    localNickname: ""
                }
                ListElement {
                    pubKey: "0x02342342342"
                    isContact: true
                    onlineStatus: true
                    displayName: "x4 drtew5"
                    icon: ""
                    colorId: 0
                    ensName: "ens name"
                    isBlocked: false
                    alias: "some alias"
                    localNickname: ""
                }
            }
        }
    }
}
