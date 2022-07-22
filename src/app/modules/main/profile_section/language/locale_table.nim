import tables

type
  Description* = object
    name*: string
    native*: string
    flag*: string

let localeDescriptionTable* = {
    "ar": Description(name: "Arabic", native: "العربية", flag: ""),
    "bn": Description(name: "Bengali", native: "বাংলা", flag: "X"),
    "de": Description(name: "German", native: "Deutsch", flag: "🇩🇪"),
    "el": Description(name: "Greek", native: "Ελληνικά", flag: "🇬🇷"),
    "en": Description(name: "English", native: "English", flag: "🏴󠁧󠁢󠁥󠁮󠁧󠁿"),
    "en_US": Description(name: "English (United States)", native: "English (United States)", flag: "🇺🇸"),
    "es": Description(name: "Spanish", native: "Español", flag: "🇪🇸"),
    "es_419": Description(name: "Spanish (Latin America)", native: "Español (Latinoamerica)", flag: ""),
    "es_AR": Description(name: "Spanish (Argentina)", native: "Español (Argentina)", flag: "🇦🇷"),
    "fa": Description(name: "Persian", native: "فارسی", flag: "🇮🇷"),
    "fr": Description(name: "French", native: "Français", flag: "🇫🇷"),
    "he": Description(name: "Hebrew", native: "עברית'", flag: "🇮🇱"),
    "hi": Description(name: "Hindi", native: "हिन्दी", flag: "🇮🇳"),
    "hu": Description(name: "Hungarian", native: "Magyar", flag: "🇭🇺"),
    "id": Description(name: "Indonesian", native: "Bahasa Indonesia", flag: "🇮🇩"),
    "it": Description(name: "Italian", native: "Italiano", flag: "🇮🇹"),
    "ja": Description(name: "Japanese", native: "日本語", flag: "🇯🇵"),
    "ko": Description(name: "Korean", native: "한국어", flag: "🇰🇷"),
    "ms": Description(name: "Malay", native: "Bahasa Melayu", flag: "🇲🇾"),
    "ne": Description(name: "Nepali", native: "नेपाली", flag: "🇳🇵"),
    "nl": Description(name: "Dutch", native: "Nederlands", flag: "🇳🇱"),
    "pl": Description(name: "Polish", native: "Polski", flag: "🇵🇱"),
    "pt": Description(name: "Portuguese", native: "Português", flag: "🇵🇹"),
    "pt_BR": Description(name: "Portuguese (Brazil)", native: "Português (Brasil)", flag: "🇧🇷"),
    "ru": Description(name: "Russian", native: "Русский", flag: "🇷🇺"),
    "sv": Description(name: "Swedish", native: "Svenska", flag: "🇸🇪"),
    "th": Description(name: "Thai", native: "ไทย / Phasa Thai", flag: "🇹🇭"),
    "tl": Description(name: "Tagalog", native: "Tagalog", flag: "🇵🇭"),
    "tr": Description(name: "Turkish", native: "Türkçe", flag: "🇹🇷"),
    "ug": Description(name: "Uyghur", native: "Uyƣurqə / ئۇيغۇرچە", flag: "X"),
    "uk": Description(name: "Ukrainian", native: "Українська", flag: "🇺🇦"),
    "vi": Description(name: "Vietnamese", native: "Việtnam", flag: "🇻🇳"),
    "zh_CN": Description(name: "Chinese (China)", native: "中文（中國）", flag: "🇨🇳"),
    "zh_TW": Description(name: "Chinese (Taiwan)", native: "中文（台灣）", flag: "🇹🇼"),
  }.toTable()
