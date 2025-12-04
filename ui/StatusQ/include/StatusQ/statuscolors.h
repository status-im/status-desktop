#pragma once

#include <QColor>
#include <QObject>
#include <QVariantMap>

class StatusColors : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantMap colors READ colors CONSTANT)

    Q_PROPERTY(QColor black MEMBER black CONSTANT)
    Q_PROPERTY(QColor white MEMBER white CONSTANT)
    Q_PROPERTY(QColor transparent MEMBER transparent CONSTANT)

    Q_PROPERTY(QColor blue MEMBER blue CONSTANT)
    Q_PROPERTY(QColor blue2 MEMBER blue2 CONSTANT)
    Q_PROPERTY(QColor blue3 MEMBER blue3 CONSTANT)
    Q_PROPERTY(QColor blue4 MEMBER blue4 CONSTANT)
    Q_PROPERTY(QColor blue5 MEMBER blue5 CONSTANT)
    Q_PROPERTY(QColor blue6 MEMBER blue6 CONSTANT)
    Q_PROPERTY(QColor blue7 MEMBER blue7 CONSTANT)
    Q_PROPERTY(QColor blue8 MEMBER blue8 CONSTANT)

    Q_PROPERTY(QColor brown MEMBER brown CONSTANT)
    Q_PROPERTY(QColor brown2 MEMBER brown2 CONSTANT)
    Q_PROPERTY(QColor brown3 MEMBER brown3 CONSTANT)

    Q_PROPERTY(QColor cyan MEMBER cyan CONSTANT)

    Q_PROPERTY(QColor graphite MEMBER graphite CONSTANT)
    Q_PROPERTY(QColor graphite2 MEMBER graphite2 CONSTANT)
    Q_PROPERTY(QColor graphite3 MEMBER graphite3 CONSTANT)
    Q_PROPERTY(QColor graphite4 MEMBER graphite4 CONSTANT)
    Q_PROPERTY(QColor graphite5 MEMBER graphite5 CONSTANT)

    Q_PROPERTY(QColor green MEMBER green CONSTANT)
    Q_PROPERTY(QColor green2 MEMBER green2 CONSTANT)
    Q_PROPERTY(QColor green3 MEMBER green3 CONSTANT)
    Q_PROPERTY(QColor green4 MEMBER green4 CONSTANT)
    Q_PROPERTY(QColor green5 MEMBER green5 CONSTANT)
    Q_PROPERTY(QColor green6 MEMBER green6 CONSTANT)

    Q_PROPERTY(QColor grey MEMBER grey CONSTANT)
    Q_PROPERTY(QColor grey2 MEMBER grey2 CONSTANT)
    Q_PROPERTY(QColor grey3 MEMBER grey3 CONSTANT)
    Q_PROPERTY(QColor grey4 MEMBER grey4 CONSTANT)
    Q_PROPERTY(QColor grey5 MEMBER grey5 CONSTANT)

    Q_PROPERTY(QColor moss MEMBER moss CONSTANT)
    Q_PROPERTY(QColor moss2 MEMBER moss2 CONSTANT)

    Q_PROPERTY(QColor orange MEMBER orange CONSTANT)
    Q_PROPERTY(QColor orange2 MEMBER orange2 CONSTANT)
    Q_PROPERTY(QColor orange3 MEMBER orange3 CONSTANT)
    Q_PROPERTY(QColor orange4 MEMBER orange4 CONSTANT)

    Q_PROPERTY(QColor warning_orange MEMBER warning_orange CONSTANT)

    Q_PROPERTY(QColor purple MEMBER purple CONSTANT)

    Q_PROPERTY(QColor red MEMBER red CONSTANT)
    Q_PROPERTY(QColor red2 MEMBER red2 CONSTANT)
    Q_PROPERTY(QColor red3 MEMBER red3 CONSTANT)

    Q_PROPERTY(QColor turquoise MEMBER turquoise CONSTANT)
    Q_PROPERTY(QColor turquoise2 MEMBER turquoise2 CONSTANT)
    Q_PROPERTY(QColor turquoise3 MEMBER turquoise3 CONSTANT)
    Q_PROPERTY(QColor turquoise4 MEMBER turquoise4 CONSTANT)

    Q_PROPERTY(QColor violet MEMBER violet CONSTANT)

    Q_PROPERTY(QColor yellow MEMBER yellow CONSTANT)
    Q_PROPERTY(QColor yellow2 MEMBER yellow2 CONSTANT)

    Q_PROPERTY(QColor blueHijab MEMBER blueHijab CONSTANT)

    Q_PROPERTY(QColor lightPattensBlue MEMBER lightPattensBlue CONSTANT)

    Q_PROPERTY(QColor blackHovered MEMBER blackHovered CONSTANT)
    Q_PROPERTY(QColor blueHovered MEMBER blueHovered CONSTANT)
    Q_PROPERTY(QColor purpleHovered MEMBER purpleHovered CONSTANT)
    Q_PROPERTY(QColor cyanHovered MEMBER cyanHovered CONSTANT)
    Q_PROPERTY(QColor violetHovered MEMBER violetHovered CONSTANT)
    Q_PROPERTY(QColor redHovered MEMBER redHovered CONSTANT)
    Q_PROPERTY(QColor yellowHovered MEMBER yellowHovered CONSTANT)
    Q_PROPERTY(QColor greenHovered MEMBER greenHovered CONSTANT)
    Q_PROPERTY(QColor mossHovered MEMBER mossHovered CONSTANT)
    Q_PROPERTY(QColor brownHovered MEMBER brownHovered CONSTANT)
    Q_PROPERTY(QColor brown2Hovered MEMBER brown2Hovered CONSTANT)

    Q_PROPERTY(QColor lightDesktopBlue10 MEMBER lightDesktopBlue10 CONSTANT)
    Q_PROPERTY(QColor darkDesktopBlue10 MEMBER darkDesktopBlue10 CONSTANT)

public:
    explicit StatusColors(QObject* parent = nullptr);

    static const QVariantMap& colors();

    Q_INVOKABLE static QColor getColor(const QString& name, qreal alpha = -1);
    Q_INVOKABLE static QColor alphaColor(const QColor& color, qreal alpha);

    static constexpr QColor black = QColor(0x00, 0x00, 0x00);
    static constexpr QColor white = QColor(0xFF, 0xFF, 0xFF);
    static constexpr QColor transparent = QColor(0x00, 0x00, 0x00, 0x00);

    static constexpr QColor blue = QColor(0x43, 0x60, 0xDF);
    static constexpr QColor blue2 = QColor(0x29, 0x46, 0xC4);
    static constexpr QColor blue3 = QColor(0x88, 0xB0, 0xFF);
    static constexpr QColor blue4 = QColor(0x86, 0x9E, 0xFF);
    static constexpr QColor blue5 = QColor(0xAA, 0xC6, 0xFF);
    static constexpr QColor blue6 = QColor(0xEC, 0xEF, 0xFC);
    static constexpr QColor blue7 = QColor(0x09, 0x10, 0x1C);
    static constexpr QColor blue8 = QColor(0x6B, 0x6F, 0x76);

    static constexpr QColor brown = QColor(0x8B, 0x31, 0x31);
    static constexpr QColor brown2 = QColor(0x9B, 0x83, 0x2F);
    static constexpr QColor brown3 = QColor(0xAD, 0x43, 0x43);

    static constexpr QColor cyan = QColor(0x51, 0xD0, 0xF0);

    static constexpr QColor graphite = QColor(0x21, 0x21, 0x21);
    static constexpr QColor graphite2 = QColor(0x25, 0x25, 0x25);
    static constexpr QColor graphite3 = QColor(0x2C, 0x2C, 0x2C);
    static constexpr QColor graphite4 = QColor(0x37, 0x37, 0x37);
    static constexpr QColor graphite5 = QColor(0x90, 0x90, 0x90);

    static constexpr QColor green = QColor(0x4E, 0xBC, 0x60);
    static constexpr QColor green2 = QColor(0x7C, 0xDA, 0x00);
    static constexpr QColor green3 = QColor(0x60, 0xC3, 0x70);
    static constexpr QColor green4 = QColor(0x93, 0xDB, 0x33);
    static constexpr QColor green5 = QColor(0x9E, 0xA8, 0x5D);
    static constexpr QColor green6 = QColor(0xAF, 0xB5, 0x51);

    static constexpr QColor grey = QColor(0xF0, 0xF2, 0xF5);
    static constexpr QColor grey2 = QColor(0xF6, 0xF8, 0xFA);
    static constexpr QColor grey3 = QColor(0xE9, 0xED, 0xF1);
    static constexpr QColor grey4 = QColor(0xEE, 0xF2, 0xF5);
    static constexpr QColor grey5 = QColor(0x93, 0x9B, 0xA1);

    static constexpr QColor moss = QColor(0x26, 0xA6, 0x9A);
    static constexpr QColor moss2 = QColor(0x10, 0xA8, 0x8E);

    static constexpr QColor orange = QColor(0xFE, 0x8F, 0x59);
    static constexpr QColor orange2 = QColor(0xFF, 0x9F, 0x0F);
    static constexpr QColor orange3 = QColor(0xFF, 0xA6, 0x7B);
    static constexpr QColor orange4 = QColor(0xFE, 0x8F, 0x59);

    static constexpr QColor warning_orange = QColor(0xF6, 0x79, 0x3C);

    static constexpr QColor purple = QColor(0x88, 0x7A, 0xF9);

    static constexpr QColor red = QColor(0xFF, 0x2D, 0x55);
    static constexpr QColor red2 = QColor(0xFA, 0x65, 0x65);
    static constexpr QColor red3 = QColor(0xFF, 0x5C, 0x7B);

    static constexpr QColor turquoise = QColor(0x0D, 0xA4, 0xC9);
    static constexpr QColor turquoise2 = QColor(0x07, 0xBC, 0xE9);
    static constexpr QColor turquoise3 = QColor(0x7B, 0xE5, 0xFF);
    static constexpr QColor turquoise4 = QColor(0x0D, 0xA4, 0xC9);

    static constexpr QColor violet = QColor(0xD3, 0x7E, 0xF4);

    static constexpr QColor yellow = QColor(0xFF, 0xCA, 0x0F);
    static constexpr QColor yellow2 = QColor(0xEA, 0xD2, 0x7B);

    static constexpr QColor blueHijab = QColor(0xCD, 0xF2, 0xFB);

    static constexpr QColor lightPattensBlue = QColor(0xD7, 0xDE, 0xE4);

    static constexpr QColor blackHovered = QColor(0x1D, 0x23, 0x2E);
    static constexpr QColor blueHovered = QColor(0x36, 0x4D, 0xB2);
    static constexpr QColor purpleHovered = QColor(0x6D, 0x62, 0xC7);
    static constexpr QColor cyanHovered = QColor(0x41, 0xA6, 0xC0);
    static constexpr QColor violetHovered = QColor(0xA9, 0x65, 0xC3);
    static constexpr QColor redHovered = QColor(0xC8, 0x51, 0x51);
    static constexpr QColor yellowHovered = QColor(0xCC, 0xA2, 0x0C);
    static constexpr QColor greenHovered = QColor(0x63, 0xAE, 0x00);
    static constexpr QColor mossHovered = QColor(0x1E, 0x85, 0x7B);
    static constexpr QColor brownHovered = QColor(0x6F, 0x27, 0x27);
    static constexpr QColor brown2Hovered = QColor(0x7C, 0x69, 0x26);

    static constexpr QColor lightDesktopBlue10 = QColor(0xEC, 0xEF, 0xFB);
    static constexpr QColor darkDesktopBlue10 = QColor(0x27, 0x32, 0x51);
};
