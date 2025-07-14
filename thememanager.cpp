#include "thememanager.h"
#include <QDebug>


ThemeManager::ThemeManager(QObject* parent) : QObject(parent) {
    applyTheme("dark");
}

QString ThemeManager::theme() const
{
    return m_theme;
}

void ThemeManager:: setTheme(const QString& theme) {
    if(m_theme == theme) {
        return;
    }

    applyTheme(theme);
    emit themeChanged();
    emit colorsChanged();
}


QColor ThemeManager:: background() const {
    return m_palette.background;
}
QColor ThemeManager:: text() const {
    return m_palette.text;
}
QColor ThemeManager:: figure() const {
    return m_palette.figure;
}

QColor ThemeManager::inputBackground() const
{
    return m_palette.inputBackground;
}

QColor ThemeManager::placeHolderText() const
{
    return m_palette.placeHolderText;
}

QColor ThemeManager::buttonHoverColor() const
{
    return m_palette.buttonHoverColor;
}

QColor ThemeManager::inputTextColor() const
{
    return m_palette.inputTextColor;
}

QColor ThemeManager::highlight() const
{
    return m_palette.highlight;
}

QColor ThemeManager::highlightedText() const
{
    return m_palette.highlightedText;
}

QColor ThemeManager:: border() const {
    return m_palette.border;
}
QColor ThemeManager:: button() const {
    return m_palette.button;
}

void ThemeManager:: applyTheme(const QString& theme) {
    m_theme = theme;
    if (theme == "dark") {
        m_palette.background = QColor("#121212");  // Более глубокий темный фон, как в Material Design
        m_palette.text = QColor("#EEEEEE");        // Чуть более яркий серый текст для лучшей читаемости
        m_palette.button = QColor("#2D3748");      // Синевато-серый для кнопок, более мягкий
        m_palette.border = QColor("#3D4852");      // Светлее бордер для лучшей видимости
        m_palette.figure = QColor("#1A202C");      // Темно-синий для фигур
        m_palette.buttonHoverColor = QColor("#4A5568"); // Более нейтральный цвет при наведении
        m_palette.inputBackground = QColor("#1D1D1D"); // Чуть светлее фон для текстовых полей
        m_palette.placeHolderText = QColor("#A0AEC0"); // Голубовато-серый для placeholder
        m_palette.inputTextColor = QColor("#FFFFFF");  // Белый текст в полях ввода
        m_palette.highlight = QColor("#4A5AFF");       // Яркий синий для выделения фигуры
        m_palette.highlightedText = QColor("#FFFFFF"); // Белый для выделенного текста
    } else if (theme == "light") {
        m_palette.background = QColor("#F7FAFC");   // Очень светлый фон с легким оттенком синего
        m_palette.text = QColor("#2D3748");         // Темно-синий текст для контраста
        m_palette.button = QColor("#4299E1");       // Яркий но не кричащий синий для кнопок
        m_palette.border = QColor("#CBD5E0");       // Мягкий серый бордер
        m_palette.figure = QColor("#FFFFFF");       // Белый для фигур
        m_palette.buttonHoverColor = QColor("#3182CE"); // Более насыщенный синий при наведении
        m_palette.inputBackground = QColor("#FFFFFF"); // Белый фон для полей ввода
        m_palette.placeHolderText = QColor("#A0AEC0"); // Серо-голубой для placeholder
        m_palette.inputTextColor = QColor("#2D3748");  // Темно-синий для текста в полях
        m_palette.highlight = QColor("#63B3ED");       // Яркий голубой для выделения фигуры
        m_palette.highlightedText = QColor("#FFFFFF"); // Белый для выделенного текста
    } else if (theme == "colorful") {
        m_palette.background = QColor("#FAFAFA");     // Почти белый фон для контраста
        m_palette.text = QColor("#2A4365");           // Глубокий синий для текста
        m_palette.button = QColor("#ED8936");         // Яркий оранжевый для кнопок
        m_palette.border = QColor("#F6AD55");         // Светлый оранжевый для бордеров
        m_palette.figure = QColor("#F56565");         // Теплый красный для фигур
        m_palette.buttonHoverColor = QColor("#DD6B20"); // Темный оранжевый при наведении
        m_palette.inputBackground = QColor("#FFFFFF"); // Белый фон для полей ввода
        m_palette.placeHolderText = QColor("#A0AEC0"); // Серо-голубой для placeholder
        m_palette.inputTextColor = QColor("#2A4365");  // Глубокий синий для текста
        m_palette.highlight = QColor("#9C4221");       // Глубокий терракотовый для выделения фигуры
        m_palette.highlightedText = QColor("#FFFAF0"); // Кремовый для выделенного текста
    } else if (theme == "neutral") {
        m_palette.background = QColor("#F5F5F5");   // Светло-серый фон
        m_palette.text = QColor("#333333");         // Почти черный текст для четкости
        m_palette.button = QColor("#9CA3AF");       // Серый для кнопок средней насыщенности
        m_palette.border = QColor("#D1D5DB");       // Серебристый бордер
        m_palette.figure = QColor("#E5E7EB");       // Светло-серый для фигур
        m_palette.buttonHoverColor = QColor("#6B7280"); // Темно-серый при наведении
        m_palette.inputBackground = QColor("#FFFFFF"); // Белый фон для полей ввода
        m_palette.placeHolderText = QColor("#9CA3AF"); // Серый для placeholder
        m_palette.inputTextColor = QColor("#333333");  // Почти черный текст
        m_palette.highlight = QColor("#4B5563");       // Темно-серый для выделения фигуры
        m_palette.highlightedText = QColor("#FFFFFF"); // Белый для выделенного текста
    } else if (theme == "watercolor") {
        m_palette.background = QColor("#F8F4F9");   // Нежный светло-лавандовый фон
        m_palette.text = QColor("#5B4B8A");         // Глубокий лавандово-фиолетовый для текста
        m_palette.button = QColor("#AE8DBE");       // Мягкий пурпурный для кнопок
        m_palette.border = QColor("#D7BDE2");       // Нежный лавандовый бордер
        m_palette.figure = QColor("#E2D5E7");       // Светло-лавандовый для фигур
        m_palette.buttonHoverColor = QColor("#9B72AA"); // Более насыщенный лавандовый при наведении
        m_palette.inputBackground = QColor("#FDF8FF"); // Очень светлый лавандовый для фона ввода
        m_palette.placeHolderText = QColor("#B8A9C9"); // Нежный серо-лавандовый для placeholder
        m_palette.inputTextColor = QColor("#5B4B8A");  // Глубокий лавандовый для текста
        m_palette.highlight = QColor("#805AD5");       // Насыщенный фиолетовый для выделения фигуры
        m_palette.highlightedText = QColor("#FFFFFF"); // Белый для выделенного текста
    } else if (theme == "retro") {
        m_palette.background = QColor("#282828");   // Глубокий коричнево-серый фон
        m_palette.text = QColor("#EBDBB2");         // Теплый кремовый для текста
        m_palette.button = QColor("#D79921");       // Глубокий янтарный для кнопок
        m_palette.border = QColor("#665C54");       // Землистый бордер
        m_palette.figure = QColor("#504945");       // Темно-коричневый для фигур
        m_palette.buttonHoverColor = QColor("#FE8019"); // Яркий оранжевый при наведении
        m_palette.inputBackground = QColor("#3C3836"); // Темно-коричневый фон для ввода
        m_palette.placeHolderText = QColor("#A89984"); // Приглушенный бежевый для placeholder
        m_palette.inputTextColor = QColor("#EBDBB2");  // Теплый кремовый для текста
        m_palette.highlight = QColor("#B8BB26");       // Желтовато-зеленый для выделения фигуры
        m_palette.highlightedText = QColor("#282828"); // Темный фон для выделенного текста
    }
}
