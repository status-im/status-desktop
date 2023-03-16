import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

Row {
    id: root

    property bool isContact: false
    property int trustIndicator: StatusContactVerificationIcons.TrustedType.None
    property bool tiny: true

    property StatusAssetSettings mutualConnectionIcon: StatusAssetSettings {
        name: root.tiny ? "tiny/tiny-contact" : "tiny/contact"
        color: Theme.palette.indirectColor1
        width: Math.min(bgWidth, dummyImage.width)
        height: Math.min(bgHeight, dummyImage.height)
        bgWidth: root.tiny ? 10 : 16.5
        bgHeight: root.tiny ? 10 : 16.5
        bgColor: Theme.palette.primaryColor1
        // Only used to get implicit width and height from the actual image
        property Image dummyImage: Image {
            source: mutualConnectionIcon.name ? "../../assets/img/icons/" + mutualConnectionIcon.name + ".svg": ""
            visible: false
        }
    }

    property StatusAssetSettings trustContactIcon: StatusAssetSettings {
        // None and Untrustworthy types, same aspect (Icon will not be visible in case of None type):
        name: root.trustIndicator === StatusContactVerificationIcons.TrustedType.Verified ? root.tiny ? "tiny/tiny-checkmark" : "tiny/checkmark"
                                                                                          : root.tiny ? "tiny/tiny-exclamation" : "tiny/exclamation"
        color: Theme.palette.indirectColor1
        width: Math.min(bgWidth, dummyImage.width)
        height: Math.min(bgHeight, dummyImage.height)
        bgWidth: root.tiny ? 10 : 16
        bgHeight: root.tiny ? 10 : 16
        bgColor: root.trustIndicator === StatusContactVerificationIcons.TrustedType.Verified ? Theme.palette.primaryColor1 : Theme.palette.dangerColor1
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
    visible: root.isContact || (root.trustIndicator !== StatusContactVerificationIcons.TrustedType.None)

    HoverHandler {
        id: hoverHandler
    }

    StatusToolTip {
        text: {
            if (root.isContact) {
                if (root.trustIndicator === StatusContactVerificationIcons.TrustedType.Verified)
                    return qsTr("Verified contact")
                if (root.trustIndicator === StatusContactVerificationIcons.TrustedType.Untrustworthy)
                    return qsTr("Untrustworthy contact")
                return qsTr("Contact")
            }
            if (root.trustIndicator === StatusContactVerificationIcons.TrustedType.Untrustworthy)
                return qsTr("Untrustworthy")
            return ""
        }

        visible: hoverHandler.hovered && text
    }

    StatusRoundIcon {
        visible: root.isContact && root.trustIndicator !== StatusContactVerificationIcons.TrustedType.Verified
        asset: root.mutualConnectionIcon
    }

    StatusRoundIcon {
        visible: root.trustIndicator !== StatusContactVerificationIcons.TrustedType.None
        asset: root.trustContactIcon
    }
 }
