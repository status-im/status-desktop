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

    property QtObject codeFont: FontLoader {
        source: "../../../assets/fonts/RobotoMono/RobotoMono-Regular.ttf"
    }

    property QtObject codeFontThin: FontLoader {
        source: "../../../assets/fonts/RobotoMono/RobotoMono-Thin.ttf"
    }

    property QtObject codeFontExtraLight: FontLoader {
        source: "../../../assets/fonts/RobotoMono/RobotoMono-ExtraLight.ttf"
    }

    property QtObject codeFontLight: FontLoader {
        source: "../../../assets/fonts/RobotoMono/RobotoMono-Light.ttf"
    }

    property QtObject codeFontMedium: FontLoader {
        source: "../../../assets/fonts/RobotoMono/RobotoMono-Medium.ttf"
    }

    property QtObject codeFontBold: FontLoader {
        source: "../../../assets/fonts/RobotoMono/RobotoMono-Bold.ttf"
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
    miscColor12: getColor('green6')

    userCustomizationColors: [
        "#AAC6FF",
        "#887AF9",
        "#51D0F0",
        "#D37EF4",
        "#FA6565",
        "#FFCA0F",
        "#93DB33",
        "#10A88E",
        "#AD4343",
        "#EAD27B",
        "silver", // update me when figma is ready
        "darkgrey", // update me when figma is ready
    ]

    identiconRingColors: ["#000000", "#726F6F", "#C4C4C4", "#E7E7E7", "#FFFFFF", "#00FF00",
                          "#009800", "#B8FFBB", "#FFC413", "#9F5947", "#FFFF00", "#A8AC00",
                          "#FFFFB0", "#FF5733", "#FF0000", "#9A0000", "#FF9D9D", "#FF0099",
                          "#C80078", "#FF00FF", "#900090", "#FFB0FF", "#9E00FF", "#0000FF",
                          "#000086", "#9B81FF", "#3FAEF9", "#9A6600", "#00FFFF", "#008694",
                          "#C2FFFF", "#00F0B6"]

    property QtObject statusAppLayout: QtObject {
        property color backgroundColor: baseColor3
        property color rightPanelBackgroundColor: baseColor3
    }

    property QtObject statusAppNavBar: QtObject {
        property color backgroundColor: baseColor5
    }

    property QtObject statusToastMessage: QtObject {
        property color backgroundColor: baseColor3
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

    property QtObject statusSwitchTab: QtObject {
        property color backgroundColor: baseColor3
    }

    property QtObject statusSelect: QtObject {
        property color menuItemBackgroundColor: baseColor2
        property color menuItemHoverBackgroundColor: directColor7
    }
}

