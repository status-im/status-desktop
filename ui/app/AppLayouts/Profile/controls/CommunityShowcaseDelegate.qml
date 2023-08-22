import QtQuick 2.15

import utils 1.0

ShowcaseDelegate {
    title: !!showcaseObj && !!showcaseObj.name ? showcaseObj.name : ""
    secondaryTitle: !!showcaseObj && (showcaseObj.memberRole === Constants.memberRole.owner ||
                                      showcaseObj.memberRole === Constants.memberRole.admin ||
                                      showcaseObj.memberRole === Constants.memberRole.tokenMaster) ? qsTr("Admin") : qsTr("Member")
    hasImage: !!showcaseObj && !!showcaseObj.image

    icon.name: !!showcaseObj ? showcaseObj.name : ""
    icon.source: !!showcaseObj ? showcaseObj.image : ""
    icon.color: !!showcaseObj ? showcaseObj.color : "transparent"
}
