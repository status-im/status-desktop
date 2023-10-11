import QtQuick 2.15

import utils 1.0

ShowcaseDelegate {
    title: !!showcaseObj ? showcaseObj.name : ""
    secondaryTitle: !!showcaseObj ? showcaseObj.secondaryTitle : ""

    hasImage: !!showcaseObj && !!showcaseObj.image
    hasEmoji: !!showcaseObj && !!showcaseObj.emoji
    hasIcon: !hasEmoji

    icon.name: !!showcaseObj ? showcaseObj.name : ""
    icon.source: !!showcaseObj ? showcaseObj.image : ""
    icon.color: {
        if (!showcaseObj) {
            return "transparent"
        }
        if (howcaseObj.colorId) {
            return Utils.getColorForId(showcaseObj.colorId)
        }
        if (showcaseObj.color) {
            return showcaseObj.color
        }
        return Theme.palette.primaryColor3
    }

    bgRadius: Style.current.radius
    bgColor: !!showcaseObj && !!showcaseObj.backgroundColor ? showcaseObj.backgroundColor : "transparent"
}
