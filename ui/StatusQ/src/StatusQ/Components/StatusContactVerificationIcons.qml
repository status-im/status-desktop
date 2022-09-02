import QtQuick 2.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Row {
    id: root

    property bool isContact: false
    property var trustIndicator: StatusContactVerificationIcons.TrustedType.None

    property StatusAssetSettings mutualConnectionIcon: StatusAssetSettings {
        name: "tiny/tiny-contact"
        color: Theme.palette.indirectColor1
        width: dummyImage.width
        height: dummyImage.height
        bgWidth: 10
        bgHeight: 10
        bgColor: Theme.palette.primaryColor1
        // Only used to get implicit width and height from the actual image
        property Image dummyImage: Image {
            source: mutualConnectionIcon.name ? "../../assets/img/icons/" + mutualConnectionIcon.name + ".svg": ""
            visible: false
        }
    }

    property StatusAssetSettings trustContactIcon: StatusAssetSettings {
        // None and Untrustworthy types, same aspect (Icon will not be visible in case of None type):
        name: root.trustIndicator === StatusContactVerificationIcons.TrustedType.Verified ? "tiny/tiny-checkmark" : "tiny/subtract"
        color: Theme.palette.indirectColor1
        width: dummyImage.width
        height: dummyImage.height
        bgWidth: 10
        bgHeight: 10
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

    StatusRoundIcon {
        visible: root.isContact
        asset.name: root.mutualConnectionIcon.name
        asset.width: root.mutualConnectionIcon.width
        asset.height: root.mutualConnectionIcon.height
        asset.rotation: root.mutualConnectionIcon.rotation
        asset.color: root.mutualConnectionIcon.color
        asset.bgColor: root.mutualConnectionIcon.bgColor
        asset.bgWidth: root.mutualConnectionIcon.bgWidth
        asset.bgHeight: root.mutualConnectionIcon.bgHeight
    }

    StatusRoundIcon {
        visible: root.trustIndicator !== StatusContactVerificationIcons.TrustedType.None
        asset.name: root.trustContactIcon.name
        asset.width: root.trustContactIcon.width
        asset.height: root.trustContactIcon.height
        asset.rotation: root.trustContactIcon.rotation
        asset.color: root.trustContactIcon.color
        asset.bgColor: root.trustContactIcon.bgColor
        asset.bgWidth: root.trustContactIcon.bgWidth
        asset.bgHeight: root.trustContactIcon.bgHeight
    }
 }
