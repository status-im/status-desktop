import tables

type
  State* {.pure.} = enum
    Alpha  # 30-90% translations done
    Beta   # >90% translations done
    Stable # >90% translations done and reviewed

  Description* = object
    name*: string
    native*: string
    flag*: string
    state*: State

let localeDescriptionTable* = {
    "ar": Description(name: "Arabic", native: "العربية", flag: "", state: State.Alpha),
    "bn": Description(name: "Bengali", native: "বাংলা", flag: "X", state: State.Alpha),
    "de": Description(name: "German", native: "Deutsch", flag: "🇩🇪", state: State.Alpha),
    "el": Description(name: "Greek", native: "Ελληνικά", flag: "🇬🇷", state: State.Alpha),
    "en": Description(name: "English", native: "English", flag: "🏴󠁧󠁢󠁥󠁮󠁧󠁿", state: State.Stable),
    "en_US": Description(name: "English (United States)", native: "English (United States)", flag: "🇺🇸", state: State.Alpha),
    "es": Description(name: "Spanish", native: "Español", flag: "🇪🇸", state: State.Alpha),
    "es_419": Description(name: "Spanish (Latin America)", native: "Español (Latinoamerica)", flag: "", state: State.Alpha),
    "es_AR": Description(name: "Spanish (Argentina)", native: "Español (Argentina)", flag: "🇦🇷", state: State.Alpha),
    "fa": Description(name: "Persian", native: "فارسی", flag: "🇮🇷", state: State.Alpha),
    "fr": Description(name: "French", native: "Français", flag: "🇫🇷", state: State.Alpha),
    "he": Description(name: "Hebrew", native: "עברית'", flag: "🇮🇱", state: State.Alpha),
    "hi": Description(name: "Hindi", native: "हिन्दी", flag: "🇮🇳", state: State.Alpha),
    "hu": Description(name: "Hungarian", native: "Magyar", flag: "🇭🇺", state: State.Alpha),
    "id": Description(name: "Indonesian", native: "Bahasa Indonesia", flag: "🇮🇩", state: State.Alpha),
    "it": Description(name: "Italian", native: "Italiano", flag: "🇮🇹", state: State.Alpha),
    "ja": Description(name: "Japanese", native: "日本語", flag: "🇯🇵", state: State.Alpha),
    "ko": Description(name: "Korean", native: "한국어", flag: "🇰🇷", state: State.Alpha),
    "ms": Description(name: "Malay", native: "Bahasa Melayu", flag: "🇲🇾", state: State.Alpha),
    "ne": Description(name: "Nepali", native: "नेपाली", flag: "🇳🇵", state: State.Alpha),
    "nl": Description(name: "Dutch", native: "Nederlands", flag: "🇳🇱", state: State.Alpha),
    "pl": Description(name: "Polish", native: "Polski", flag: "🇵🇱", state: State.Alpha),
    "pt": Description(name: "Portuguese", native: "Português", flag: "🇵🇹", state: State.Alpha),
    "pt_BR": Description(name: "Portuguese (Brazil)", native: "Português (Brasil)", flag: "🇧🇷", state: State.Alpha),
    "ru": Description(name: "Russian", native: "Русский", flag: "🇷🇺", state: State.Alpha),
    "sv": Description(name: "Swedish", native: "Svenska", flag: "🇸🇪", state: State.Alpha),
    "th": Description(name: "Thai", native: "ไทย / Phasa Thai", flag: "🇹🇭", state: State.Alpha),
    "tl": Description(name: "Tagalog", native: "Tagalog", flag: "🇵🇭", state: State.Alpha),
    "tr": Description(name: "Turkish", native: "Türkçe", flag: "🇹🇷", state: State.Alpha),
    "ug": Description(name: "Uyghur", native: "Uyƣurqə / ئۇيغۇرچە", flag: "X", state: State.Alpha),
    "uk": Description(name: "Ukrainian", native: "Українська", flag: "🇺🇦", state: State.Alpha),
    "vi": Description(name: "Vietnamese", native: "Việtnam", flag: "🇻🇳", state: State.Alpha),
    "zh_CN": Description(name: "Chinese (China)", native: "中文（中國）", flag: "🇨🇳", state: State.Alpha),
    "zh_TW": Description(name: "Chinese (Taiwan)", native: "中文（台灣）", flag: "🇹🇼", state: State.Alpha),
  }.toTable()
