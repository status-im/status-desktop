import QtQuick 2.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Row {
    id: root

    property bool isMutualContact: false
    property var trustIndicator: StatusContactVerificationIcons.TrustedType.None

    property StatusIconSettings mutualConnectionIcon: StatusIconSettings {
        name: "tiny/tiny-contact"
        color: Theme.palette.indirectColor1
        width: dummyImage.width
        height: dummyImage.height
        background: StatusIconBackgroundSettings {
            width: 10
            height: 10
            color: Theme.palette.primaryColor1
        }
        // Only used to get implicit width and height from the actual image
        property Image dummyImage: Image {
            source: mutualConnectionIcon.name ? "../../assets/img/icons/" + mutualConnectionIcon.name + ".svg": ""
            visible: false
        }
    }

    property StatusIconSettings trustContactIcon: StatusIconSettings {
        // None and Untrustworthy types, same aspect (Icon will not be visible in case of None type):
        name: root.trustIndicator === StatusContactVerificationIcons.TrustedType.Verified ? "tiny/tiny-checkmark" : "tiny/subtract"
        color: Theme.palette.indirectColor1
        width: dummyImage.width
        height: dummyImage.height
        background: StatusIconBackgroundSettings {
            width: 10
            height: 10
            color: root.trustIndicator === StatusContactVerificationIcons.TrustedType.Verified ? Theme.palette.primaryColor1 : Theme.palette.dangerColor1
        }
        // Only used to get implicit width and height from the actual image
        property Image dummyImage: Image {
            source: trustContactIcon.name ? "../../assets/img/icons/" + trustContactIcon.name + ".svg": ""
            visible: false
        }
    }

    enum TrustedType {
        None, //0
        Verified, //1
        Untrustworthy //2
    }

    spacing: 4
    visible: root.isMutualContact || (root.trustIndicator !== StatusContactVerificationIcons.TrustedType.None)

    StatusRoundIcon {
        visible: root.isMutualContact
        icon.name: root.mutualConnectionIcon.name
        icon.width: root.mutualConnectionIcon.width
        icon.height: root.mutualConnectionIcon.height
        icon.rotation: root.mutualConnectionIcon.rotation
        icon.color: root.mutualConnectionIcon.color
        icon.background.color: root.mutualConnectionIcon.background.color
        icon.background.width: root.mutualConnectionIcon.background.width
        icon.background.height: root.mutualConnectionIcon.background.height
    }

    StatusRoundIcon {
        visible: root.trustIndicator !== StatusContactVerificationIcons.TrustedType.None
        icon.name: root.trustContactIcon.name
        icon.width: root.trustContactIcon.width
        icon.height: root.trustContactIcon.height
        icon.rotation: root.trustContactIcon.rotation
        icon.color: root.trustContactIcon.color
        icon.background.color: root.trustContactIcon.background.color
        icon.background.width: root.trustContactIcon.background.width
        icon.background.height: root.trustContactIcon.background.height
    }
 }
