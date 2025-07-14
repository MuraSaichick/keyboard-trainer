#include "keyboardhandler.h"


KeyboardHandler::KeyboardHandler(QObject *parent)
    : QObject(parent), m_X(0), m_Y(0), m_positionLetter(0), startNewline(0),m_enteredWordsCount(0) , m_isMethodLocked(false),   m_font("Arial", 40),                 // или значения по умолчанию
    m_fontMetrics(m_font), m_letterSpacing(5), m_wrongPressCount(0), m_isFirstError(true), m_isVertical(true){}

void KeyboardHandler::setOriginalString(const QString &original) {
    m_originalString = original;
    m_textSize = m_originalString.length();
}

void KeyboardHandler::setModifiedString(const QString &modified) {
    m_modifiedString = modified;
    m_wrongPressCount = 0;
    m_isFirstError = true;
}

void KeyboardHandler::startPositionLater()
{
    m_positionLetter = 0;
    startNewline = 0;
    m_X = 0;
    m_Y = 0;
    emit cursorChanged(m_X);
    return;
}

void KeyboardHandler::inputCharacter(QChar character) {
    if(m_isMethodLocked) {
        return;
    }
    m_expectedChar = character;
    checkKeyPress(m_positionLetter);
}

QString KeyboardHandler::getModifiedString() const {
    return m_modifiedString;
}

void KeyboardHandler::checkKeyPress(int positionLetter) {
    if(m_originalString[positionLetter] == m_expectedChar) {
        qDebug() << "правильно нажато";
        if(!m_isFirstError) {
            m_isFirstError = true;
        }
        if (m_positionLetter < m_originalString.length()) {
            QString targetLetter = m_originalString.mid(positionLetter, 1);
            QString coloredLetter = QString("<span style='color:#32CD32;'>%1</span>")
                                        .arg(targetLetter);

            m_sizeSpanGreen = coloredLetter.length();
            m_modifiedString.replace(positionLetter * m_sizeSpanGreen, 1, coloredLetter);
            emit textChanged();
            m_positionLetter++;
            m_fontMetrics = QFontMetrics(m_font);
            qDebug() << "буква: " << QString(m_originalString.at(m_positionLetter - 1)) << " шрифт: " << m_fontFamily << "ширина: " << m_fontMetrics.horizontalAdvance(m_originalString.at(m_positionLetter - 1));
            updateCursorPosition();
            if(!m_isVertical && m_positionLetter > 0) {
                emit scrollHorizontalRequested(m_X);
            }
            qDebug() << "Курсор меняется стал: " << m_X;
            if(m_originalString[m_positionLetter - 1] == ' ' || m_originalString[m_positionLetter - 1] == '-') {
                setEnteredWords(m_enteredWordsCount + 1);
                if(m_isVertical) {
                qDebug() << "Сработал scrollIfTextOverflows";
                scrollIfTextOverflows();
                }
            } else if(m_textSize == m_positionLetter) {
                qDebug() << "Текст завершился";
                emit textEntryCompleted();
                return;
            }
            emit cursorChanged(m_X);
        } else {
            qDebug() << "Достигнут конец текста";
        }
    } else {
        qDebug() << "Не правильно нажато!!!";
        if(m_isFirstError) {
            m_wrongPressCount++;
            m_isFirstError = false;
            qDebug() << "Увеличили количество ошибок: " << m_wrongPressCount;
        }
        m_isMethodLocked = true;
        emit isMethodLockedChanged();
        QString targetLetter = m_originalString.mid(m_positionLetter, 1);
        QString errorLetter = QString("<span style='background-color:red;'>%1</span>")
                                  .arg(targetLetter);

        QString originalLetter = targetLetter;

        m_modifiedString.replace(m_positionLetter * m_sizeSpanGreen, 1, errorLetter);
        emit textChanged();
        // Вернуть исходный стиль через таймер
        QTimer::singleShot(50, [this, originalLetter, errorLetter]() {
            m_modifiedString.replace(m_positionLetter * m_sizeSpanGreen,errorLetter.length(), originalLetter);
            emit textChanged();
            m_isMethodLocked = false;
            emit isMethodLockedChanged();
        });

    }
}

bool KeyboardHandler::isMethodLocked()
{
    return m_isMethodLocked;
}

void KeyboardHandler::setEnteredWords(int enteredWords)
{
    if(m_enteredWordsCount == enteredWords) {
        return;
    }
    m_enteredWordsCount = enteredWords;
    emit enteredWordsChanged();
}

void KeyboardHandler::setIsMethodLocked(bool newMethod)
{
    if(m_isMethodLocked != newMethod) {
        m_isMethodLocked = newMethod;
        emit isMethodLockedChanged();
    }
}

void KeyboardHandler::setTextWidth(double width)
{
    m_widthText = width;
    return;
}

void KeyboardHandler::setPosition(int x, int y) {
    m_X = x;
    m_Y = y;
}

int KeyboardHandler::getX() const {
    return m_X;
}

int KeyboardHandler::getY() const {
    return m_Y;
}

int KeyboardHandler::getEnteredWords()
{
    return m_enteredWordsCount;
}

void KeyboardHandler::setFontSize(int size)
{
    qDebug() << "передаем fontSize в fontMetrics: " << size;
    if(m_fontSize == size) {
        return;
    }
    m_fontSize = size;
    setFontMetrics();
}

void KeyboardHandler::setFontFamily(const QString &family)
{
    if(m_fontFamily == family) {
        return;
    }
    m_fontFamily = family;
    setFontMetrics();
}

void KeyboardHandler::setFontLetterSpacing(int letterSpacing)
{
    if(m_letterSpacing == letterSpacing) {
        return;
    }
    m_letterSpacing = letterSpacing;
    setFontMetrics();
}

int KeyboardHandler::getFontSize() const
{
    return m_fontSize;
}

QString KeyboardHandler::getFontFamily() const
{
    return m_fontFamily;
}

int KeyboardHandler::getLineSpacingText() const
{
    return m_fontMetrics.lineSpacing();
}

int KeyboardHandler::getCorrectKeyCount() const
{
    return m_positionLetter;
}

double KeyboardHandler::getPressAccuracy()
{
    double pressAccuracy = static_cast<double>(100.0 - static_cast<double>(m_wrongPressCount) / static_cast<double>(m_positionLetter) * 100.0);
    qDebug() << "не обрезанная аккуратность: " << pressAccuracy << "кол-во ошибок: " << m_wrongPressCount;
    pressAccuracy = std::trunc(pressAccuracy * 100.0) / 100.0;
    qDebug() << "обрезанная аккуратность: " << pressAccuracy;
    return pressAccuracy;
}

KeyboardHandler *KeyboardHandler::self()
{
    return this;
}

void KeyboardHandler::setIsVertical(bool isVertical)
{
    m_isVertical = isVertical;
}

void KeyboardHandler::setFontMetrics()
{
    qDebug() << "setFontMetrics():";
    qDebug() << "  m_fontSize =" << m_fontSize;
    qDebug() << "  m_fontFamily =" << m_fontFamily;
    qDebug() << "  m_letterSpacing =" << m_letterSpacing;
    m_font.setFamily(m_fontFamily);
    m_font.setPixelSize(m_fontSize);
    m_font.setLetterSpacing(QFont::AbsoluteSpacing, m_letterSpacing);
    qDebug() << "LetterSpacing который добавляем: " << m_font.letterSpacing();
    m_fontMetrics = QFontMetrics(m_font);
}

void KeyboardHandler::scrollIfTextOverflows()
{
    QString nextWord = "";

    int index = m_positionLetter;

    // Сначала проверяем, что index не вышел за пределы строки
    while(index < m_originalString.length() && !(m_originalString[index] == ' ' || m_originalString[index] == '-')) {
        nextWord += m_originalString[index];
        index++;
    }

    qDebug() <<"следующее слово: " << nextWord;

    // Берём подстроку от начала новой строки до конца следующего слова (index)
    QString substring = m_originalString.mid(startNewline, m_positionLetter - startNewline) + nextWord;

    qDebug() << "подстрока: " << substring;
    qDebug() << "размер подстроки: " << m_fontMetrics.horizontalAdvance(substring) << "ширина поля: " << m_widthText;

    if(m_fontMetrics.horizontalAdvance(substring) > m_widthText) {
        m_X = 0;
        startNewline = m_positionLetter;  // сдвигаем начало новой строки на начало следующего слова
        emit scrollChanged();
        return;
    }
}

void KeyboardHandler::updateCursorPosition()
{
    QString subStr = m_originalString.mid(startNewline, m_positionLetter - startNewline);
    m_X = m_fontMetrics.horizontalAdvance(subStr);
    // Теперь m_X — позиция курсора (в пикселях) после введенных символов
    emit cursorChanged(m_X);
}
