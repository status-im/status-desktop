import QtQuick 2.15

import StatusQ.Core.Theme 0.1

ShowcaseDelegate {
    title: !!showcaseObj && !!showcaseObj.name ? showcaseObj.name : ""
    secondaryTitle: !!showcaseObj && !!showcaseObj.address ? showcaseObj.address : ""
    hasEmoji: !!showcaseObj && !!showcaseObj.emoji
    hasIcon: !hasEmoji
    icon.name: hasEmoji ? showcaseObj.emoji : "filled-account"
    icon.color: !!showcaseObj && showcaseObj.color ? showcaseObj.color : Theme.palette.primaryColor3
}
