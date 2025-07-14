#ifndef KEYBOARDHANDLER_H
#define KEYBOARDHANDLER_H
#pragma once

#include <QObject>
#include <QString>
#include <QFont>
#include <QFontMetrics>
#include <QDebug>
#include <QTimer>

class KeyboardHandler : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool isMethodLocked READ isMethodLocked WRITE setIsMethodLocked NOTIFY isMethodLockedChanged)

public:
    explicit KeyboardHandler(QObject *parent = nullptr);

    // Установить текущую позицию (для вызова из QML)
    Q_INVOKABLE void setPosition(int x, int y);
    // Для размера и типа букв при измении положения курсора
    Q_INVOKABLE void setFontSize(int size);
    Q_INVOKABLE void setFontFamily(const QString &family);
    Q_INVOKABLE void setFontLetterSpacing(int letterSpacing);
    Q_INVOKABLE KeyboardHandler* self();
    Q_INVOKABLE void setIsVertical(bool isVertical);

    // Проверка правильности нажатия клавиши
    void checkKeyPress(int positionLetter);

   bool isMethodLocked();

public slots:
    void setEnteredWords(int enteredWords);
    void setIsMethodLocked(bool newMethod);
    void setTextWidth(double width);
    // Установить исходную строку
    void setOriginalString(const QString &original);
    // Установить изменённую строку
    void setModifiedString(const QString &modified);
    void startPositionLater();
    // Принять введённый символ
    void inputCharacter(QChar character);
    // Получить изменённую строку
    QString getModifiedString() const;
    // Получить текущую позицию
    int getX() const;
    int getY() const;
    int getEnteredWords();
    int getFontSize() const;
    QString getFontFamily() const;
    int getLineSpacingText() const;
    int getCorrectKeyCount() const;
    double getPressAccuracy();


signals:
    void textChanged();
    void isMethodLockedChanged();
    void cursorChanged(int x);
    void scrollChanged();
    void scrollHorizontalRequested(int offset);
    void enteredWordsChanged();
    void textEntryCompleted();

private:
    // основные лень расписывать
    int m_textSize;
    int startNewline;
    double m_widthText;
    bool m_isMethodLocked;
    bool m_isVertical;
    int m_positionLetter;
    QChar m_expectedChar;
    int m_enteredWordsCount;
    int m_wrongPressCount;
    bool m_isFirstError;
    int m_sizeSpanGreen;

    // Текст
    QString m_originalString;
    QString m_modifiedString;

    // Курсор
    int m_X;
    int m_Y;

    // Вид текста
    int m_fontSize;
    QString m_fontFamily;
    QFont m_font;
    QFontMetrics m_fontMetrics;
    int m_letterSpacing;
    void setFontMetrics();

    // функция на проверку конца строки
    void scrollIfTextOverflows();
    void updateCursorPosition();
};

#endif
