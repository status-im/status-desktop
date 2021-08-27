import QtQuick 2.13

ThemePalette {

    name: "dark"

    property QtObject baseFont: FontLoader {
        source: "../../../assets/fonts/Inter/Inter-Regular.otf"
    }

    property QtObject baseFontThin: FontLoader {
        source: "../../../assets/fonts/Inter/Inter-Thin.otf"
    }

    property QtObject baseFontExtraLight: FontLoader {
        source: "../../../assets/fonts/Inter/Inter-ExtraLight.otf"
    }

    property QtObject baseFontLight: FontLoader {
        source: "../../../assets/fonts/Inter/Inter-Light.otf"
    }

    property QtObject baseFontMedium: FontLoader {
        source: "../../../assets/fonts/Inter/Inter-Medium.otf"
    }

    property QtObject baseFontBold: FontLoader {
        source: "../../../assets/fonts/Inter/Inter-Bold.otf"
    }

    property QtObject baseFontExtraBold: FontLoader {
        source: "../../../assets/fonts/Inter/Inter-ExtraBold.otf"
    }

    property QtObject baseFontBlack: FontLoader {
        source: "../../../assets/fonts/Inter/Inter-Black.otf"
    }

    property QtObject monoFont: FontLoader {
        source: "../../../assets/fonts/InterStatus/InterStatus-Regular.otf"
    }

    property QtObject monoFontThin: FontLoader {
        source: "../../../assets/fonts/InterStatus/InterStatus-Thin.otf"
    }

    property QtObject monoFontExtraLight: FontLoader {
        source: "../../../assets/fonts/InterStatus/InterStatus-ExtraLight.otf"
    }

    property QtObject monoFontLight: FontLoader {
        source: "../../../assets/fonts/InterStatus/InterStatus-Light.otf"
    }

    property QtObject monoFontMedium: FontLoader {
        source: "../../../assets/fonts/InterStatus/InterStatus-Medium.otf"
    }

    property QtObject monoFontBold: FontLoader {
        source: "../../../assets/fonts/InterStatus/InterStatus-Bold.otf"
    }

    property QtObject monoFontExtraBold: FontLoader {
        source: "../../../assets/fonts/InterStatus/InterStatus-ExtraBold.otf"
    }

    property QtObject monoFontBlack: FontLoader {
        source: "../../../assets/fonts/InterStatus/InterStatus-Black.otf"
    }

    property color dropShadow: getColor('black', 0.08)

    baseColor1: getColor('graphite5')
    baseColor2: getColor('graphite4')
    baseColor3: getColor('graphite3')
    baseColor4: getColor('graphite2')
    baseColor5: getColor('graphite')

    primaryColor1: getColor('blue3')
    primaryColor2: getColor('blue4', 0.3)
    primaryColor3: getColor('blue4', 0.2)

    dangerColor1: getColor('red3')
    dangerColor2: getColor('red3', 0.3)
    dangerColor3: getColor('red3', 0.2)

    successColor1: getColor('green3')
    successColor2: getColor('green3', 0.2)

    mentionColor1: getColor('turquoise3')
    mentionColor2: getColor('turquoise4', 0.3)
    mentionColor3: getColor('turquoise4', 0.2)
    mentionColor4: getColor('turquoise4', 0.1)

    pinColor1: getColor('orange3')
    pinColor2: getColor('orange4', 0.2)
    pinColor3: getColor('orange4', 0.1)

    directColor1: getColor('white')
    directColor2: getColor('white', 0.9)
    directColor3: getColor('white', 0.8)
    directColor4: getColor('white', 0.7)
    directColor5: getColor('white', 0.4)
    directColor6: getColor('white', 0.2)
    directColor7: getColor('white', 0.1)
    directColor8: getColor('white', 0.05)
    directColor9: getColor('white', 0.2)

    indirectColor1: getColor('black')
    indirectColor2: getColor('black', 0.7)
    indirectColor3: getColor('black', 0.4)

    miscColor1: getColor('blue5')
    miscColor2: getColor('purple')
    miscColor3: getColor('cyan')
    miscColor4: getColor('violet')
    miscColor5: getColor('red2')
    miscColor6: getColor('orange')
    miscColor7: getColor('yellow')
    miscColor8: getColor('green4')
    miscColor9: getColor('moss2')
    miscColor10: getColor('brown3')
    miscColor11: getColor('yellow2')

    property QtObject statusAppLayout: QtObject {
        property color backgroundColor: baseColor3
        property color rightPanelBackgroundColor: baseColor3
    }

    property QtObject statusAppNavBar: QtObject {
        property color backgroundColor: baseColor5
    }

    property QtObject statusListItem: QtObject {
        property color backgroundColor: baseColor3
        property color secondaryHoverBackgroundColor: primaryColor3
    }

    property QtObject statusChatListItem: QtObject {
        property color hoverBackgroundColor: directColor8
        property color selectedBackgroundColor: directColor7
    }

    property QtObject statusChatListCategoryItem: QtObject {
        property color buttonHoverBackgroundColor: directColor7
    }

    property QtObject statusNavigationListItem: QtObject {
        property color hoverBackgroundColor: directColor8
        property color selectedBackgroundColor: directColor7
    }

    property QtObject statusBadge: QtObject {
        property color foregroundColor: baseColor3
        property color borderColor: baseColor5
        property color hoverBorderColor: "#353A4D"
    }

    property QtObject statusChatInfoButton: QtObject {
        property color backgroundColor: baseColor3
    }

    property QtObject statusPopupMenu: QtObject {
        property color backgroundColor: baseColor2
        property color hoverBackgroundColor: directColor7
        property color separatorColor: directColor7
    }

    property QtObject statusModal: QtObject {
        property color backgroundColor: baseColor3
    }

    property QtObject statusRoundedImage: QtObject {
        property color backgroundColor: baseColor3
    }

    property QtObject statusChatInput: QtObject {
        property color secondaryBackgroundColor: "#414141"
    }
}

