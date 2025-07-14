#include "randomtextgenerator.h"



RandomTextGenerator::RandomTextGenerator(QObject *parent) : QObject(parent)
{
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", "TextGenerator");
    db.setDatabaseName("./Assets/database/TextElements.db");

    if (!db.open()) {
        qCritical() << "Не удалось открыть базу данных!";
    } else {
        qDebug() << "База данных успешно открыта.";
    }
}

void RandomTextGenerator::startTest(const QString &testType, const QString& language, int wordCount, int timeLimitSeconds, bool withPunctuation, bool withNumbers)
{

    m_timeLimitSeconds = timeLimitSeconds;
    m_testType = testType;
    m_wordCount = wordCount;
    m_withNumbers = withNumbers;
    m_withPunctuation = withPunctuation;
    m_language = language;
    if(testType == "text") {
        generateRandomText();
    } else if(testType == "words") {
        generateRandomWords();
    }
    else if(testType == "time") {
        m_wordCount = m_timeLimitSeconds * 3;
        generateRandomWords();
        }

}

void RandomTextGenerator::generateRandomWords()
{
    // Открытие базы данных
    QSqlDatabase db = QSqlDatabase::database("TextGenerator");
    if (!db.isOpen()) {
        qDebug() << "База данных не открыта!";
        return;
    }

    QString table = (m_language == "ru") ? "russian_words" : "english_words";
    QRandomGenerator *randomGen = QRandomGenerator::global();
    QString text;

    // Получаем общее количество строк в таблице слов
    QSqlQuery countQuery(db);
    countQuery.prepare(QString("SELECT COUNT(*) FROM %1").arg(table));
    if (!countQuery.exec()) {
        qDebug() << "Ошибка при получении количества записей: " << countQuery.lastError();
        return;
    }
    countQuery.next();
    int totalRows = countQuery.value(0).toInt();

    if (totalRows == 0) {
        qDebug() << "Нет слов в таблице!";
        return;
    }

    QSqlQuery wordQuery(db);
    int totalItems = m_wordCount;
    QStringList generatedItems;

    for (int i = 0; i < totalItems; ++i) {
        bool insertNumber = m_withNumbers && randomGen->bounded(100) < 30; // Примерно 30% шанс вставить число

        if (insertNumber) {
            int randomNumber = randomGen->bounded(0, 10000);
            generatedItems << QString::number(randomNumber);
        } else {
            int randomId = randomGen->bounded(1, totalRows + 1);
            wordQuery.prepare(QString("SELECT word FROM %1 WHERE id = :id").arg(table));
            wordQuery.bindValue(":id", randomId);
            if (wordQuery.exec() && wordQuery.next()) {
                generatedItems << wordQuery.value(0).toString();
            }
        }
    }

    // Если нужны знаки пунктуации
    if (m_withPunctuation) {
        QSqlQuery punctuationQuery(db);
        punctuationQuery.prepare("SELECT mark FROM punctuation_marks");
        if (!punctuationQuery.exec()) {
            qDebug() << "Ошибка при получении знаков пунктуации: " << punctuationQuery.lastError();
            return;
        }

        QStringList punctuationMarks;
        while (punctuationQuery.next()) {
            punctuationMarks.append(punctuationQuery.value(0).toString());
        }

        int punctuationCount = generatedItems.size() * 0.2;

        for (int i = 0; i < punctuationCount && !punctuationMarks.isEmpty(); ++i) {
            int punctIndex = randomGen->bounded(punctuationMarks.size());
            int insertPos = randomGen->bounded(generatedItems.size() + 1);
            generatedItems.insert(insertPos, punctuationMarks[punctIndex]);
        }
    }

    // Собираем финальный текст
    text = generatedItems.join(" ");
    m_text = text.trimmed();
    emit textChanged(m_text);
}


void RandomTextGenerator::generateRandomText()
{
    // Открытие базы данных
    QSqlDatabase db = QSqlDatabase::database("TextGenerator");
    if (!db.isOpen()) {
        qDebug() << "База данных не открыта!";
        return;
    }

    // Определяем таблицу в зависимости от языка
    QString table = (m_language == "ru") ? "russian_texts" : "english_texts";

    // Запрос на получение общего числа записей в выбранной таблице
    QSqlQuery countQuery(db);
    countQuery.prepare(QString("SELECT COUNT(*) FROM %1").arg(table));

    if (!countQuery.exec()) {
        qDebug() << "Ошибка при получении количества записей: " << countQuery.lastError();
        return;
    }

    // Получаем количество строк в таблице
    countQuery.next();
    int totalRows = countQuery.value(0).toInt();

    if (totalRows == 0) {
        qDebug() << "Нет записей в таблице!";
        return;
    }

    // Генерируем случайное число для выбора строки
    int randomId = QRandomGenerator::global()->bounded(totalRows) + 1;  // В БД ID могут начинаться с 1

    // Выполняем запрос для получения текста с выбранным случайным ID
    QSqlQuery query(db);
    query.prepare(QString("SELECT text FROM %1 WHERE id = :id").arg(table));
    query.bindValue(":id", randomId);

    if (!query.exec()) {
        qDebug() << "Ошибка при получении случайного текста: " << query.lastError();
        return;
    }

    // Извлекаем текст из результата запроса
    if (query.next()) {
        m_text = query.value(0).toString();  // Присваиваем значение переменной m_text
        emit textChanged(m_text);
        return;
    } else {
        qDebug() << "Текст не найден для данного ID!";
    }
}
