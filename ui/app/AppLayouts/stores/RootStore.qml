import QtQuick 2.13

QtObject {
    id: root
    property var chatsModelInst: chatsModel
    property var walletModelInst: walletModel
    property var profileModelInst: profileModel
    property MessageStore messageStore: MessageStore { }
}
