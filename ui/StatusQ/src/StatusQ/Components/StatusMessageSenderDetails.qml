import QtQuick 2.15

import StatusQ.Core 0.1

QtObject {
    id: root

    property string id: ""
    property string compressedPubKey: ""
    property string displayName: ""
    property bool usesDefaultName: false
    property string secondaryName: ""

    property bool isEnsVerified: false
    property bool isContact: false
    property int trustIndicator: StatusContactVerificationIcons.TrustedType.None

    property string badgeImage: ""

    property StatusProfileImageSettings profileImage: StatusProfileImageSettings {
        pubkey: root.id
        showRing: !root.isEnsVerified
        width: 40
        height: 40
    }
}
