#ifndef THEMEMANAGER_H
#define THEMEMANAGER_H

#pragma once
#include <QObject>
#include <QString>
#include <QColor>

struct ThemePalette
{
    QColor background; // Задний фон
    QColor text; // обычный текст
    QColor placeHolderText; // текст на заднем плане для ввода в поле
    QColor button; // для кнопок
    QColor border; // для бортиков
    QColor figure; // для фигур
    QColor inputBackground; // фон полей для ввода
    QColor buttonHoverColor; // при наведении на кнопку
    QColor inputTextColor; // цвет текста в полях для ввода
    QColor highlight; // цвет выделения фигуры
    QColor highlightedText; // цвет выделения текста

};

class ThemeManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString theme READ theme WRITE setTheme NOTIFY themeChanged)

    Q_PROPERTY(QColor background READ background NOTIFY colorsChanged)
    Q_PROPERTY(QColor text READ text NOTIFY colorsChanged)
    Q_PROPERTY(QColor  button READ button NOTIFY colorsChanged)
    Q_PROPERTY(QColor border READ border NOTIFY colorsChanged)
    Q_PROPERTY(QColor figure READ figure NOTIFY colorsChanged)
    Q_PROPERTY(QColor placeHolderText READ placeHolderText NOTIFY colorsChanged)
    Q_PROPERTY(QColor inputBackground READ inputBackground NOTIFY colorsChanged)
    Q_PROPERTY(QColor buttonHoverColor READ buttonHoverColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor inputTextColor READ inputTextColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor  highlight READ highlight  NOTIFY colorsChanged)
    Q_PROPERTY(QColor  highlightedText READ highlightedText  NOTIFY colorsChanged)

public:


    explicit ThemeManager(QObject* parent = nullptr);

    QColor background() const;
    QColor text() const;
    QColor button() const;
    QColor border() const;
    QColor figure() const;
    QColor inputBackground() const;
    QColor placeHolderText() const;
    QColor buttonHoverColor() const;
    QColor inputTextColor() const;
    QColor highlight() const;
    QColor highlightedText() const;

    QString theme() const;

public slots:
    void setTheme(const QString& theme);

signals:
    void themeChanged();
    void colorsChanged();
private:

    void applyTheme(const QString& theme);

    QString m_theme;
    ThemePalette m_palette;
};

#endif // THEMEMANAGER_H
