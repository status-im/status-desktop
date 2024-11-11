import QtQuick 2.13

import StatusQ.Core 0.1

QtObject {
    id: msgDetails

    property bool amISender: false
    property StatusMessageSenderDetails sender: StatusMessageSenderDetails { }
    property bool isEdited: false
    property int contentType: 0
    property string messageText: ""
    property string messageContent: ""
    property string messageOriginInfo: ""
    property bool messageDeleted: false
    property var album: []
    property int albumCount: 0
}
