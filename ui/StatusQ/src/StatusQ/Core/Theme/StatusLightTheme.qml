import QtQuick 2.13

ThemePalette {

    name: "light"

    baseColor1: getColor('grey5')
    baseColor2: getColor('grey4')
    baseColor3: getColor('grey3')
    baseColor4: getColor('grey2')
    baseColor5: getColor('grey')

    primaryColor1: getColor('blue')
    primaryColor2: getColor('blue', 0.2)
    primaryColor3: getColor('blue', 0.1)

    dangerColor1: getColor('red')
    dangerColor2: getColor('red', 0.2)
    dangerColor3: getColor('red', 0.1)

    warningColor1: getColor('warning_orange')
    warningColor2: getColor('warning_orange', 0.2)
    warningColor3: getColor('warning_orange', 0.1)

    successColor1: getColor('green')
    successColor2: getColor('green', 0.1)
    successColor3: getColor('green', 0.2)

    mentionColor1: getColor('turquoise')
    mentionColor2: getColor('turquoise2', 0.3)
    mentionColor3: getColor('turquoise2', 0.2)
    mentionColor4: getColor('turquoise2', 0.1)

    pinColor1: getColor('orange')
    pinColor2: getColor('orange2', 0.2)
    pinColor3: getColor('orange2', 0.1)

    directColor1: getColor('black')
    directColor2: getColor('black', 0.9)
    directColor3: getColor('black', 0.8)
    directColor4: getColor('black', 0.7)
    directColor5: getColor('black', 0.4)
    directColor6: getColor('black', 0.3)
    directColor7: getColor('black', 0.1)
    directColor8: getColor('black', 0.05)
    directColor9: getColor('black', 0.2)

    indirectColor1: getColor('white')
    indirectColor2: getColor('white', 0.7)
    indirectColor3: getColor('white', 0.4)
    indirectColor4: getColor('white')

    miscColor1: getColor('blue2')
    miscColor2: getColor('purple')
    miscColor3: getColor('cyan')
    miscColor4: getColor('violet')
    miscColor5: getColor('red2')
    miscColor6: getColor('orange')
    miscColor7: getColor('yellow')
    miscColor8: getColor('green2')
    miscColor9: getColor('moss')
    miscColor10: getColor('brown')
    miscColor11: getColor('brown2')
    miscColor12: getColor('green5')

    dropShadow2: getColor('blue7', 0.02)

    statusFloatingButtonHighlight: getColor('blueHijab')

    statusLoadingHighlight: getColor('lightPattensBlue', 0.5)
    statusLoadingHighlight2: indirectColor3

    messageHighlightColor: getColor('blue', 0.2)

    userCustomizationColors: [
        "#2946C4",
        "#887AF9",
        "#51D0F0",
        "#D37EF4",
        "#FA6565",
        "#FFCA0F",
        "#7CDA00",
        "#26A69A",
        "#8B3131",
        "#9B832F",
        "silver", // update me when figma is ready
        "darkgrey", // update me when figma is ready
    ]

    identiconRingColors: ["#000000", "#726F6F", "#C4C4C4", "#E7E7E7", "#FFFFFF", "#00FF00",
                          "#009800", "#B8FFBB", "#FFC413", "#9F5947", "#FFFF00", "#A8AC00",
                          "#FFFFB0", "#FF5733", "#FF0000", "#9A0000", "#FF9D9D", "#FF0099",
                          "#C80078", "#FF00FF", "#900090", "#FFB0FF", "#9E00FF", "#0000FF",
                          "#000086", "#9B81FF", "#3FAEF9", "#9A6600", "#00FFFF", "#008694",
                          "#C2FFFF", "#00F0B6"]

    blockProgressBarColor: baseColor3

    statusAppLayout: QtObject {
        property color backgroundColor: white
        property color rightPanelBackgroundColor: white
    }

    statusAppNavBar: QtObject {
        property color backgroundColor: baseColor2
    }

    statusToastMessage: QtObject {
        property color backgroundColor: white
    }

    statusListItem: QtObject {
        property color backgroundColor: white
        property color secondaryHoverBackgroundColor: getColor('blue6')
        property color highlightColor: getColor('blue', 0.05)
    }

    statusChatListItem: QtObject {
        property color hoverBackgroundColor: baseColor2
        property color selectedBackgroundColor: baseColor3
    }

    statusChatListCategoryItem: QtObject {
        property color buttonHoverBackgroundColor: directColor8
    }

    statusNavigationListItem: QtObject {
        property color hoverBackgroundColor: baseColor2
        property color selectedBackgroundColor: baseColor3
    }

    statusBadge: QtObject {
        property color foregroundColor: white
        property color borderColor: baseColor4
        property color hoverBorderColor: "#DDE3F3"
    }

    statusChatInfoButton: QtObject {
        property color backgroundColor: white
    }

    statusMenu: QtObject {
        property color backgroundColor: white
        property color hoverBackgroundColor: baseColor2
        property color separatorColor: baseColor2
    }

    statusModal: QtObject {
        property color backgroundColor: white
    }

    statusRoundedImage: QtObject {
        property color backgroundColor: white
    }

    statusChatInput: QtObject {
        property color secondaryBackgroundColor: "#E2E6E8"
    }

    statusSelect: QtObject {
        property color menuItemBackgroundColor: white
        property color menuItemHoverBackgroundColor: baseColor2
    }

    statusMessage: QtObject {
        property color emojiReactionBackground: "#e2e6e9"
        property color emojiReactionBackgroundHovered: "#d7dadd"
        property color emojiReactionActiveBackground: getColor('blue')
        property color emojiReactionActiveBackgroundHovered: Qt.darker(emojiReactionActiveBackground, 1.1)
    }

    customisationColors: QtObject {
        property color blue: "#2A4AF5"
        property color purple: "#7140FD"
        property color orange: "#FF7D46"
        property color army: "#216266"
        property color turquoise: "#2A799B"
        property color sky: "#1992D7"
        property color yellow: "#F6AF3C"
        property color pink: "#F66F8F"
        property color copper:"#CB6256"
        property color camel: "#C78F67"
        property color magenta: "#EC266C"
        property color yinYang: "#09101C"
    }
}
