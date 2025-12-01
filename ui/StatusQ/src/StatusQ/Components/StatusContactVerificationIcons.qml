import QtQuick

import StatusQ.Core
import StatusQ.Controls
import StatusQ.Core.Theme

Row {
    id: root

    property bool isContact: false
    property int trustIndicator: StatusContactVerificationIcons.TrustedType.None
    property bool isBlocked
    property bool tiny: true

    property StatusAssetSettings mutualConnectionIcon: StatusAssetSettings {
        name: root.tiny ? "tiny/tiny-contact" : "tiny/contact"
        color: root.Theme.palette.indirectColor1
        width: Math.min(bgWidth, dummyImage.width)
        height: Math.min(bgHeight, dummyImage.height)
        bgWidth: root.tiny ? 10 : 16.5
        bgHeight: root.tiny ? 10 : 16.5
        bgRadius: bgWidth / 2
        bgColor: root.Theme.palette.primaryColor1
        // Only used to get implicit width and height from the actual image
        property Image dummyImage: Image {
            source: mutualConnectionIcon.name ? Qt.resolvedUrl("../../assets/img/icons/" + mutualConnectionIcon.name + ".svg"): ""
            visible: false
            cache: false
        }
    }

    property StatusAssetSettings trustContactIcon: StatusAssetSettings {
        // None and Untrustworthy types, same aspect (Icon will not be visible in case of None type):
        name: root.trustIndicator === StatusContactVerificationIcons.TrustedType.Verified ? root.tiny ? "tiny/tiny-checkmark" : "tiny/checkmark"
                                                                                          : root.tiny ? "tiny/tiny-exclamation" : "tiny/exclamation"
        color: root.Theme.palette.indirectColor1
        width: Math.min(bgWidth, dummyImage.width)
        height: Math.min(bgHeight, dummyImage.height)
        bgWidth: root.tiny ? 10 : 16
        bgHeight: root.tiny ? 10 : 16
        bgRadius: bgWidth / 2
        bgColor: root.trustIndicator === StatusContactVerificationIcons.TrustedType.Verified ? root.Theme.palette.successColor1
                                                                                             : root.Theme.palette.dangerColor1
        // Only used to get implicit width and height from the actual image
        property Image dummyImage: Image {
            source: trustContactIcon.name ? Qt.resolvedUrl("../../assets/img/icons/" + trustContactIcon.name + ".svg"): ""
            visible: false
            cache: false
        }
    }

    property StatusAssetSettings blockedContactIcon: StatusAssetSettings {
        name: root.isBlocked ? "cancel" : ""
        color: root.Theme.palette.dangerColor1
        width: Math.min(bgWidth, dummyImage.width)
        height: Math.min(bgHeight, dummyImage.height)
        bgWidth: root.tiny ? 10 : 16
        bgHeight: root.tiny ? 10 : 16
        bgRadius: bgWidth / 2
        // Only used to get implicit width and height from the actual image
        property Image dummyImage: Image {
            source: blockedContactIcon.name ? Qt.resolvedUrl("../../assets/img/icons/" + blockedContactIcon.name + ".svg"): ""
            visible: false
            cache: false
        }
    }

    enum TrustedType {
        None, //0
        Verified, //1
        Untrustworthy //2
    }

    spacing: 4
    visible: root.isContact || root.isBlocked || (root.trustIndicator !== StatusContactVerificationIcons.TrustedType.None)

    HoverHandler {
        id: hoverHandler
    }

    StatusToolTip {
        text: {
            if (root.isBlocked)
                return qsTr("Blocked")
            if (root.isContact) {
                if (root.trustIndicator === StatusContactVerificationIcons.TrustedType.Verified)
                    return qsTr("Trusted contact")
                if (root.trustIndicator === StatusContactVerificationIcons.TrustedType.Untrustworthy)
                    return qsTr("Untrusted contact")
                return qsTr("Contact")
            }
            if (root.trustIndicator === StatusContactVerificationIcons.TrustedType.Untrustworthy)
                return qsTr("Untrusted")
            return ""
        }

        visible: hoverHandler.hovered && text
    }

    // blocked
    StatusRoundIcon {
        visible: root.isBlocked
        asset: root.blockedContactIcon
    }

    // (un)trusted
    StatusRoundIcon {
        visible: !root.isBlocked && (root.trustIndicator === StatusContactVerificationIcons.TrustedType.Untrustworthy ||
                                     (root.isContact && trustIndicator === StatusContactVerificationIcons.TrustedType.Verified))
        asset: root.trustContactIcon
    }

    // contact?
    StatusRoundIcon {
        visible: !root.isBlocked && root.isContact && root.trustIndicator !== StatusContactVerificationIcons.TrustedType.Verified
        asset: root.mutualConnectionIcon
    }
}
