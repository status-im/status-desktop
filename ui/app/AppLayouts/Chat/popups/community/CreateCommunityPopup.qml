import QtQuick 2.14
import QtQuick.Dialogs 1.3

import utils 1.0
import shared.panels 1.0
import shared.popups 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import "../../panels/communities"

StatusModal {
    id: popup

    property var store
    property var communitySectionModule
    property bool isEdit: false
    property QtObject community: null
    property var onSave: () => {}

    onOpened: {
        if (isEdit) {
            contentItem.name.input.text = community.name;
            contentItem.description.input.text = community.description;
            contentItem.color = community.color;
            if (community.largeImage) {
                contentItem.image.selectedImage = community.largeImage;
            }
            contentItem.requestToJoin.checked = community.access === Constants.communityChatOnRequestAccess;
        }
        contentItem.forceNameFocus();
    }
    onClosed: destroy()

    width: 680
    implicitHeight: 820
    leftPadding: 16
    rightPadding: 16

    header.title: isEdit ? qsTr("Edit Community") : qsTr("Create New Community")

    contentItem: CommunityEditSettingsPanel {
        id: contentItem
        isEdit: popup.isEdit
        communityHistoryArchiveSupportEnabled: popup.store.isCommunityHistoryArchiveSupportEnabled
    }

    leftButtons: [
        StatusRoundButton {
            id: btnBack
            visible: isEdit
            icon.name: "arrow-right"
            icon.width: 20
            icon.height: 16
            rotation: 180
            onClicked: popup.destroy()
        }
    ]

    rightButtons: [
        StatusButton {
            id: btnCreateEdit
            enabled: popup.contentItem.isFormValid
            text: isEdit ? qsTr("Save") : qsTr("Next")
            onClicked: {
                if (!popup.contentItem.isFormValid) {
                    popup.contentItem.scrollBackUp();
                    return;
                }

                let error = false;
                let requestToJoin = popup.contentItem.requestToJoin.checked ? Constants.communityChatOnRequestAccess
                                                                            : Constants.communityChatPublicAccess;

                if (isEdit) {
                    error = communitySectionModule.editCommunity(
                        Utils.filterXSS(popup.contentItem.name),
                        Utils.filterXSS(popup.contentItem.description),
                        requestToJoin,
                        popup.contentItem.colorString,
                        // to retain the existing image, pass "" for the image path
                        popup.contentItem.image ===  community.largeImage ? "" : popup.contentItem.image,
                        popup.contentItem.imageAx,
                        popup.contentItem.imageAy,
                        popup.contentItem.imageBx,
                        popup.contentItem.imageBy,
                        popup.contentItem.historyArchive.checked,
                        popup.contentItem.pinMessagesAllMembers.checked
                  );
                } else {
                    error = popup.store.createCommunity(
                        Utils.filterXSS(popup.contentItem.name),
                        Utils.filterXSS(popup.contentItem.description),
                        requestToJoin,
                        popup.contentItem.colorString,
                        popup.contentItem.image,
                        popup.contentItem.imageAx,
                        popup.contentItem.imageAy,
                        popup.contentItem.imageBx,
                        popup.contentItem.imageBy,
                        popup.contentItem.historyArchive.checked,
                        popup.contentItem.pinMessagesAllMembers.checked
                    );
                }

                if (error) {
                    creatingError.text = error.error;
                    return creatingError.open();
                }
                popup.onSave();
                popup.close();
            }
        }
    ]

    MessageDialog {
        id: creatingError
        //% "Error creating the community"
        title: qsTrId("error-creating-the-community")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }
}

