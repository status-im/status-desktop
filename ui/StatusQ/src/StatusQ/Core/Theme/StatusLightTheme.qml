import QtQuick 2.13

ThemePalette {

    property QtObject baseFont: FontLoader {
        source: "../../../assets/fonts/Inter/Inter-Regular.otf"
    }

    property QtObject monoFont: FontLoader {
        source: "../../../assets/fonts/InterStatus/InterStatus-Regular.otf"
    }

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

    successColor1: getColor('green')
    successColor2: getColor('green', 0.1)

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

    indirectColor1: getColor('white')
    indirectColor2: getColor('white', 0.7)
    indirectColor3: getColor('white', 0.4)

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
}

