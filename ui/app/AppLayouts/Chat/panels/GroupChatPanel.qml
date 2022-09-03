import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0


RowLayout {
     id: root

     property var sectionModule
     property var chatContentModule
     property var rootStore
     property int maxHeight

     signal panelClosed()

     QtObject {
         id: d

         property ListModel groupUsersModel: ListModel { }
         property ListModel contactsModel: ListModel { }
         property var addedMembersIds: []
         property var removedMembersIds: []
         property bool isAdminMode: false

         function initialize () {
             groupUsersModel.clear()
             contactsModel.clear()
             addedMembersIds = []
             removedMembersIds = []
             tagSelector.namesModel.clear()
             for (var k = 0; k < groupUsersModelListView.count; k++) {
                 var groupEntry = groupUsersModelListView.itemAtIndex(k);
                 if (rootStore.isCurrentUser(groupEntry.pubKey) && groupEntry.isAdmin) {
                     d.isAdminMode = true;
                 }
             }
         }

         function find(val, array) {
             for(var i = 0; i < array.length; i++) {
                 if(array[i] === val) {
                     return true
                 }
             }
             return false
         }
     }

     StatusListView {
         id: groupUsersModelListView
         visible: false
         model: root.chatContentModule.usersModule.model
         delegate: Item {
             property string pubKey: model.pubKey
             property string name: model.displayName
             property bool isAdmin: model.isAdmin
         }
     }

     StatusListView {
         id: contactsModelListView
         visible: false
         model: root.rootStore.contactsModel
         delegate: Item {
             property string pubKey: model.pubKey
             property string displayName: model.displayName
             property string localNickname: model.localNickname
             property bool isVerified: model.isVerified
             property bool isUntrustworthy: model.isUntrustworthy
             property bool isContact: model.isContact
             property string icon: model.icon
             property bool onlineStatus: model.onlineStatus
         }
     }

     clip: true

     Component.onCompleted: {
         d.initialize()

         // Build groupUsersModel type from model type (to fit with expected StatusTagSelector format
         for (var i = 0; i < groupUsersModelListView.count; i ++) {
             var entry = groupUsersModelListView.itemAtIndex(i)

             // Add all group users
             d.groupUsersModel.append({pubKey: entry.pubKey,
                                       name: entry.name,
                                       tagIcon: entry.isAdmin ? "crown" : "",
                                       isReadonly: d.isAdminMode ? entry.isAdmin : !rootStore.isCurrentUser(entry.pubKey)
                                      })
         }

         // Build contactsModel type from model type (to fit with expected StatusTagSelector format
         for (var j = 0; j < contactsModelListView.count; j ++) {
             var entry2 = contactsModelListView.itemAtIndex(j)
             d.contactsModel.append({pubKey: entry2.pubKey,
                                     displayName: entry2.displayName,
                                     localNickname: entry2.localNickname,
                                     isVerified: entry2.isVerified,
                                     isUntrustworthy: entry2.isUntrustworthy,
                                     isContact: entry2.isContact,
                                     icon: entry2.icon,
                                     isImage: true,
                                     onlineStatus: entry2.onlineStatus})
         }

         // Update contacts list used by StatusTagSelector
         tagSelector.sortModel(d.contactsModel)
     }

     StatusTagSelector {
         id: tagSelector

         function memberExists(memberId) {
             var exists = false
             for (var i = 0; i < groupUsersModelListView.count; i ++) {
                 var entry = groupUsersModelListView.itemAtIndex(i)
                 if(entry.pubKey === memberId) {
                     exists = true
                     break
                 }
             }
             return exists
         }

         function addNewMember(memberId) {
            if(d.find(memberId, d.addedMembersIds)) {
                return
            }

             if(!memberExists(memberId)) {
                 d.addedMembersIds.push(memberId)
             }

             if(memberExists(memberId) && d.find(memberId, d.removedMembersIds)) {
                 d.removedMembersIds.pop(memberId)
             }
         }

         function removeExistingMember(memberId) {
             if(d.find(memberId, d.removedMembersIds)) {
                 return
             }

             if(memberExists(memberId)) {
                 d.removedMembersIds.push(memberId)
             }

             if(!memberExists(memberId) && d.find(memberId, d.addedMembersIds)) {
                 d.addedMembersIds.pop(memberId)
             }
         }

         namesModel: d.groupUsersModel
         Layout.fillWidth: true
         Layout.alignment: Qt.AlignTop | Qt.AlignLeft
         maxHeight: root.maxHeight
         nameCountLimit: 20
         showSortedListOnlyWhenText: true
         toLabelText: qsTr("To: ")
         warningText: qsTr("USER LIMIT REACHED")
         onTextChanged: sortModel(d.contactsModel)
         onAddMember: addNewMember(memberId)
         onRemoveMember: removeExistingMember(memberId)
         ringSpecModelGetter: function(pubKey) {
             return Utils.getColorHashAsJson(pubKey);
         }
         compressedKeyGetter: function(pubKey) {
             return Utils.getCompressedPk(pubKey);
         }
         colorIdForPubkeyGetter: function (pubKey) {
             return Utils.colorIdForPubkey(pubKey);
         }
     }

     StatusButton {
         id: confirmButton
         implicitHeight: 44
         Layout.alignment: Qt.AlignTop
         text: qsTr("Confirm")
         onClicked: {
             if(root.chatContentModule.chatDetails.id &&((d.addedMembersIds.length > 0) || (d.removedMembersIds.length > 0))) {
                 // Add request:
                 root.sectionModule.addGroupMembers(root.chatContentModule.chatDetails.id, JSON.stringify(d.addedMembersIds))

                 // Remove request:
                 root.sectionModule.removeMembersFromGroupChat("", root.chatContentModule.chatDetails.id, JSON.stringify(d.removedMembersIds))
             }
             root.panelClosed()
         }
     }
}
