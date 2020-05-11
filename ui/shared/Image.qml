Image {
    source: {
        if (Screen.PixelDensity < 40)
            "image_low_dpi.png"
        else if (Screen.PixelDensity > 300)
            "image_high_dpi.png"
        else
            "image.png"
    }
}