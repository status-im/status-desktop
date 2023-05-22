import QtQuick 2.13

ThemePalette {

    name: "dark"

    dropShadow: getColor('black', 0.08)

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

    warningColor1: getColor('warning_orange')
    warningColor2: getColor('warning_orange', 0.2)
    warningColor3: getColor('warning_orange', 0.1)

    successColor1: getColor('green3')
    successColor2: getColor('green3', 0.2)
    successColor3: getColor('green3', 0.3)

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

    dropShadow2: getColor('blue8', 0.02)

    statusFloatingButtonHighlight: getColor('blue4', 0.3)

    statusLoadingHighlight: getColor('white', 0.03)
    statusLoadingHighlight2: getColor('white', 0.07)

    messageHighlightColor: getColor('blue4', 0.2)

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

    blockProgressBarColor: directColor7

    statusAppLayout: QtObject {
        property color backgroundColor: baseColor3
        property color rightPanelBackgroundColor: baseColor3
    }

    statusAppNavBar: QtObject {
        property color backgroundColor: baseColor5
    }

    statusToastMessage: QtObject {
        property color backgroundColor: baseColor3
    }

    statusListItem: QtObject {
        property color backgroundColor: baseColor3
        property color secondaryHoverBackgroundColor: primaryColor3
        property color highlightColor: getColor('blue3', 0.05)
    }

    statusChatListItem: QtObject {
        property color hoverBackgroundColor: directColor8
        property color selectedBackgroundColor: directColor7
    }

    statusChatListCategoryItem: QtObject {
        property color buttonHoverBackgroundColor: directColor7
    }

    statusNavigationListItem: QtObject {
        property color hoverBackgroundColor: directColor8
        property color selectedBackgroundColor: directColor7
    }

    statusBadge: QtObject {
        property color foregroundColor: baseColor3
        property color borderColor: baseColor5
        property color hoverBorderColor: "#353A4D"
    }

    statusChatInfoButton: QtObject {
        property color backgroundColor: baseColor3
    }

    statusMenu: QtObject {
        property color backgroundColor: baseColor3
        property color hoverBackgroundColor: directColor7
        property color separatorColor: directColor7
    }

    statusModal: QtObject {
        property color backgroundColor: baseColor3
    }

    statusRoundedImage: QtObject {
        property color backgroundColor: baseColor3
    }

    statusChatInput: QtObject {
        property color secondaryBackgroundColor: "#414141"
    }

    statusSelect: QtObject {
        property color menuItemBackgroundColor: baseColor2
        property color menuItemHoverBackgroundColor: directColor7
    }

    statusMessage: QtObject {
        property color emojiReactionBackground: "#2d2823"
        property color emojiReactionBackgroundHovered: "#3a3632"
        property color emojiReactionActiveBackground: getColor('blue')
        property color emojiReactionActiveBackgroundHovered: Qt.darker(emojiReactionActiveBackground, 1.1)
    }

    customisationColors: QtObject {
        property color blue: "#223BC4"
        property color purple: "#5A33CA"
        property color orange: "#CC6438"
        property color army: "#1A4E52"
        property color turquoise: "#22617C"
        property color sky: "#1475AC"
        property color yellow: "#C58D30"
        property color pink: "#C55972"
        property color copper:"#A24E45"
        property color camel: "#9F7252"
        property color magenta: "#BD1E56"
        property color yinYang: "#FFFFFF"
    }
}
