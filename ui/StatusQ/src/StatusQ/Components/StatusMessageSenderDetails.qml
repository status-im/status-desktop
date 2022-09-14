import QtQuick 2.0
import StatusQ.Core 0.1

QtObject {
    id: root

    property string id: ""
    property string displayName: ""
    property string secondaryName: ""

    property bool isEnsVerified: false
    property bool isContact: false
    property int trustIndicator: StatusContactVerificationIcons.TrustedType.None

    property StatusProfileImageSettings profileImage: StatusProfileImageSettings {
        pubkey: root.id
        showRing: !root.isEnsVerified
        width: 40
        height: 40
    }
}
