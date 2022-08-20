import QtQuick 2.0
import StatusQ.Core 0.1

QtObject {
    id: root

    property string id: ""
    property string userName: ""
    property string ensName: ""
    property string localName: ""

    property bool isContact: false
    property int trustIndicator: StatusContactVerificationIcons.TrustedType.None

    property StatusProfileImageSettings profileImage: StatusProfileImageSettings {
        pubkey: root.id
        showRing: !root.ensName
        width: 40
        height: 40
    }

    readonly property string displayName: root.localName !== ""
                                          ? root.localName
                                          : root.ensName !== ""
                                            ? root.ensName
                                            : root.userName

    readonly property string secondaryName: root.localName === ""
                                            ? ""
                                            : root.ensName !== ""
                                              ? root.ensName
                                              : root.userName
}
