import QtQuick 2.15

QtObject {
    id: theme

    property string name

    property color black: Qt.rgba(0, 0, 0)
    property color white: Qt.rgba(1, 1, 1)
    property color transparent: "#00000000"

    property color green: getColor('green')

    property color blue: getColor('blue')
    property color darkBlue: getColor('blue2')

    property color dropShadow
    property color dropShadow2
    property color backdropColor: getColor('black', 0.4)

    property color baseColor1
    property color baseColor2
    property color baseColor3
    property color baseColor4
    property color baseColor5

    property color primaryColor1
    property color primaryColor2
    property color primaryColor3

    property color dangerColor1
    property color dangerColor2
    property color dangerColor3

    property color warningColor1
    property color warningColor2
    property color warningColor3

    property color successColor1
    property color successColor2
    property color successColor3

    property color mentionColor1
    property color mentionColor2
    property color mentionColor3
    property color mentionColor4

    property color pinColor1
    property color pinColor2
    property color pinColor3

    property color directColor1
    property color directColor2
    property color directColor3
    property color directColor4
    property color directColor5
    property color directColor6
    property color directColor7
    property color directColor8
    property color directColor9

    property color indirectColor1
    property color indirectColor2
    property color indirectColor3
    property color indirectColor4

    property color miscColor1
    property color miscColor2
    property color miscColor3
    property color miscColor4
    property color miscColor5
    property color miscColor6
    property color miscColor7
    property color miscColor8
    property color miscColor9
    property color miscColor10
    property color miscColor11
    property color miscColor12

    property color neutral95

    property color statusFloatingButtonHighlight

    property color statusLoadingHighlight
    property color statusLoadingHighlight2

    property color messageHighlightColor

    property color desktopBlue10

    property var userCustomizationColors: []

    property var identiconRingColors: []

    property color blockProgressBarColor

    // Style compat
    property color background
    property color backgroundHover: baseColor2
    property color border: baseColor2
    property color textColor: directColor1
    property color secondaryText: baseColor1
    property color separator
    property color darkGrey
    property color secondaryBackground: primaryColor2
    property color secondaryMenuBackground

    property QtObject statusAppLayout: QtObject {
        property color backgroundColor
        property color rightPanelBackgroundColor
    }

    property QtObject statusAppNavBar: QtObject {
        property color backgroundColor
    }

    property QtObject statusToastMessage: QtObject {
        property color backgroundColor
    }

    property QtObject statusListItem: QtObject {
        property color backgroundColor
        property color secondaryHoverBackgroundColor
        property color highlightColor
    }

    property QtObject statusChatListItem: QtObject {
        property color hoverBackgroundColor
        property color selectedBackgroundColor
    }

    property QtObject statusChatListCategoryItem: QtObject {
        property color buttonHoverBackgroundColor
    }

    property QtObject statusNavigationListItem: QtObject {
        property color hoverBackgroundColor
        property color selectedBackgroundColor
    }

    property QtObject statusBadge: QtObject {
        property color foregroundColor
        property color borderColor
        property color hoverBorderColor
    }

    property QtObject statusChatInfoButton: QtObject {
        property color backgroundColor
        property color hoverBackgroundColor
    }

    property QtObject statusMenu: QtObject {
        property color backgroundColor
        property color hoverBackgroundColor
        property color separatorColor
    }

    property QtObject statusModal: QtObject {
        property color backgroundColor
    }

    property QtObject statusRoundedImage: QtObject {
        property color backgroundColor
    }

    property QtObject statusChatInput: QtObject {
        property color secondaryBackgroundColor
    }

    readonly property QtObject statusSwitchTab: QtObject {
        property color buttonBackgroundColor: primaryColor1
        property color barBackgroundColor: primaryColor3
        property color selectedTextColor: indirectColor1
        property color textColor: primaryColor1
    }

    property QtObject statusSelect: QtObject {
        property color menuItemBackgroundColor
        property color menuItemHoverBackgroundColor
    }

    property QtObject statusMessage: QtObject {
        property color emojiReactionBackground
        property color emojiReactionBackgroundHovered
        property color emojiReactionActiveBackground
        property color emojiReactionActiveBackgroundHovered
    }

    property QtObject customisationColors: QtObject {
        property color blue
        property color purple
        property color orange
        property color army
        property color turquoise
        property color sky
        property color yellow
        property color pink
        property color copper
        property color camel
        property color magenta
        property color yinYang
    }

    readonly property var customisationColorsArray: [
        customisationColors.blue,
        customisationColors.purple,
        customisationColors.orange,
        customisationColors.army,
        customisationColors.turquoise,
        customisationColors.sky,
        customisationColors.yellow,
        customisationColors.pink,
        customisationColors.copper,
        customisationColors.camel,
        customisationColors.magenta,
        customisationColors.yinYang
    ]

    readonly property var communityColorsArray: [
        customisationColors.blue,
        customisationColors.yellow,
        customisationColors.magenta,
        customisationColors.purple,
        customisationColors.army,
        customisationColors.sky,
        customisationColors.orange,
        customisationColors.camel
    ]

    function alphaColor(color, alpha) {
        let actualColor = Qt.darker(color, 1)
        actualColor.a = alpha
        return actualColor
    }

    function hoverColor(normalColor) {
        return theme.name === "light" ? Qt.darker(normalColor, 1.2) : Qt.lighter(normalColor, 1.2)
    }

    function getColor(name, alpha) {
        if(StatusColors.colors[name])
            // It means name is just the key to find inside the specific `StatusColors` object
            return !!alpha ? alphaColor(StatusColors.colors[name], alpha)
                           : StatusColors.colors[name]
        else
            // It means name is directly the color itself
            return !!alpha ? alphaColor(name, alpha)
                           : name
    }
}
