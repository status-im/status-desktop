import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme
import StatusQ.Components

import AppLayouts.ActivityCenter.views
import AppLayouts.ActivityCenter.helpers

import Storybook

SplitView {
    id: root

    readonly property int leftPanelMaxWidth: 308 // It fits on mobile / portrait + desktop left panel

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Logs { id: logs }

        QtObject {
            id: notificationMock

            readonly property string id: editor.notificationBaseMock.id
            readonly property string author: editor.notificationBaseMock.title
            readonly property string chatId: editor.notificationBaseMock.id
            readonly property string sectionId: "sectionId-123"
            readonly property bool read: editor.notificationBaseMock.read
            readonly property bool dismissed: editor.notificationBaseMock.dismissed
            readonly property bool accepted: editor.notificationBaseMock.accepted
            property double timestamp: editor.notificationBaseMock.timestamp
            property QtObject message: QtObject {
                readonly property string id: "messageId-111"
                readonly property string communityId: "communityId-222"
                readonly property string messageText: editor.notificationBaseMock.description
                property bool amISender: false
                property int contentType: StatusMessage.ContentType.Text // Sticker / Unknown / Image ...
                property string messageImage: ""
                property string albumMessageImages: ""
                property int albumImagesCount: 0
                property int contactRequestState: updateRequestState(isPending.checked,
                                                                     isAccepted.checked,
                                                                     isDismissed.checked)

                function updateRequestState(isPendingRequest, isAcceptedRequest, isDismissedRequest) {
                    if(isPendingRequest) {
                        return ActivityCenterTypes.ActivityCenterContactRequestState.Pending
                    }

                    if(isAcceptedRequest) {
                        return ActivityCenterTypes.ActivityCenterContactRequestState.Accepted
                    }

                    if(isDismissedRequest) {
                        return ActivityCenterTypes.ActivityCenterContactRequestState.Dismissed
                    }
                }
            }
        }

        Item {
            SplitView.fillHeight: true
            SplitView.fillWidth: true

            ActivityNotificationContactRequest {
                anchors.centerIn: parent
                width: root.leftPanelMaxWidth
                height: implicitHeight

                notification: notificationMock
                contactsModel: QtObject{}
                contactDetails: contactEditor.contactDetailsMock

                onBlockContactRequested: (contactId, contactRequestId) =>
                                         logs.logEvent("ActivityNotificationContactRequest::onBlockContactRequested: " + contactId + ":" + contactRequestId )

                onAcceptContactRequested: (contactId, contactRequestId) =>
                                          logs.logEvent("ActivityNotificationContactRequest::onAcceptContactRequested: " + contactId + ":" + contactRequestId )

                onDeclineContactRequested: (contactId, contactRequestId) =>
                                           logs.logEvent("ActivityNotificationContactRequest::onDeclineContactRequested: " + contactId + ":" + contactRequestId )

                onOpenProfilePopup: (contactId) =>
                                    logs.logEvent("ActivityNotificationContactRequest::onOpenProfilePopup" + contactId)
            }
        }

        LogsAndControlsPanel {
            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 160

            logsView.logText: logs.logText
        }

    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ActivityNotificationBaseEditor {
            id: editor

            ActivityNotificationContactEditor {
                id: contactEditor
            }

            RadioButton {
                id: isPending
                checked: true
                text: "Is pending request?"
            }

            RadioButton {
                id: isAccepted
                text: "Is accepted request?"
            }

            RadioButton {
                id: isDismissed
                text: "Is dismissed request?"
            }
        }
    }
}
// category: Activity Center
// status: good
