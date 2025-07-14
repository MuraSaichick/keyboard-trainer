#include "userstatsmanager.h"


UserStatsManager::UserStatsManager(QObject* parent)
    : QObject(parent) {
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", "main_connection");

    db.setDatabaseName("./Assets/database/UsersDB.db");
        if (!db.open()) {
            qWarning() << "Не получилось открыть бд main_connection в userstatsmanager:" << db.lastError();
    }
}

int UserStatsManager::userId() const { return m_userId; }
QString UserStatsManager::login() const { return m_login; }


bool UserStatsManager::loadFromDatabase(int userId) {
    QSqlQuery query(QSqlDatabase::database("main_connection"));

    query.prepare(R"(
        SELECT login
        FROM user_profiles
        WHERE user_id = :userId
    )");

    query.bindValue(":userId", userId);

    if (!query.exec()) {
        qWarning() << "SELECT failed:" << query.lastError();
        return false;
    }

    if (!query.next()) {
        qWarning() << "No user with id:" << userId;
        return false;
    }

    m_userId = userId;
    m_login = query.value("login").toString();


    emit userIdChanged();
    emit loginChanged();

    return true;
}

void UserStatsManager::update_time_and_presses(int keyStrokes, int time) {
    QSqlQuery query(QSqlDatabase::database("main_connection"));

    query.prepare(R"(UPDATE user_profiles
              SET total_typing_time = total_typing_time + :time,
              total_keystrokes = total_keystrokes + :keystrokes,
              total_tests_taken = total_tests_taken + 1
              WHERE user_id = :user_id)");
    query.bindValue(":time", time);
    query.bindValue(":keystrokes", keyStrokes);
    query.bindValue(":user_id", m_userId);

    if (!query.exec()) {
        qWarning() << "Ошибка при сохранении основных результатов:" << query.lastError().text();
    }
}

QVariantMap UserStatsManager::getBasicProfileStats() {

    QVariantMap result;
    QSqlQuery query(QSqlDatabase::database("main_connection"));

    query.prepare("SELECT total_typing_time, total_keystrokes, total_tests_taken FROM user_profiles WHERE user_id = :userId");
    query.bindValue(":userId", m_userId);

    if (!query.exec()) {
        qWarning() << "Ошибка выполнения запроса getAverageTestResult:" << query.lastError().text();
        return result;
    }

    if (query.next()) {
        result["totalTypingTime"] = query.value("total_typing_time").toInt();
        result["totalKeystrokes"] = query.value("total_keystrokes").toInt();
        result["totalTestsTaken"] = query.value("total_tests_taken").toInt();
    }
    return result;
}

QVariantMap UserStatsManager::getLessonProgress(const QString &language)
{
    QSqlQuery query(QSqlDatabase::database("main_connection"));
    QString table = "UserLessons_" + language.toUpper();

    QString sql = QString(
                      "SELECT "
                      "  (SELECT COUNT(*) FROM %1 WHERE user_id = :userId) AS allLessons, "
                      "  (SELECT COUNT(*) FROM %1 WHERE user_id = :userId AND isLocked = false) AS finishedLessons"
                      ).arg(table);

    query.prepare(sql);
    query.bindValue(":userId", m_userId);

    if (!query.exec() || !query.next()) {
        qWarning() << "Ошибка при получении данных по урокам:" << query.lastError().text();
        return {};
    }
    double lessonCompletionPercent = query.value("finishedLessons").toDouble() / query.value("allLessons").toDouble();

    return {
        { "allLessons", query.value("allLessons").toInt() },
        { "finishedLessons", query.value("finishedLessons").toInt()},
        {"lessonCompletionPercent", lessonCompletionPercent}
    };
}

void UserStatsManager::updateLessonLockStatus(int lessonID, const QString &language)
{
    QSqlQuery query(QSqlDatabase::database("main_connection"));

    QString table = "UserLessons_" + language.toUpper();

    QString sql = QString("UPDATE %1 SET isLocked = false WHERE user_id = ? AND lesson_id = ?").arg(table);
    query.prepare(sql);
    query.addBindValue(m_userId);
    query.addBindValue(lessonID);
    if (!query.exec()) {
        qWarning() << "Ошибка при прохождении урока:" << query.lastError().text();
    }
}

double UserStatsManager::getTypingSpeed(const QString &language)
{
    QSqlQuery query(QSqlDatabase::database("main_connection"));

    query.prepare(R"(
        SELECT
            speed
        FROM user_results
        WHERE user_id = ?
        AND language = ?
          AND test_type = 'text'
          AND test_value = 60

    )");
    query.addBindValue(m_userId);
    query.addBindValue(language);

    if (!query.exec()) {
        qWarning() << "Ошибка при получении скорости текста:" << query.lastError().text();
    }
    if (query.next()) {
        double speed = query.value("speed").toDouble();
        return speed;
    }
    return 0;
}

void UserStatsManager::logout()
{
    QSqlQuery query(QSqlDatabase::database("main_connection"));
    query.prepare("DELETE FROM user_sessions;");
    if (!query.exec()) {
        qWarning() << "Ошибка при удалении Запомнить меня:" << query.lastError().text();
    }
    // Нет необходимости вызывать query.next() после DELETE
}

void UserStatsManager::saveTestResult(const QString &testType, const QString &language, const QString &testDetail, double speed, double accuracy, double consistency)
{
    QSqlQuery query(QSqlDatabase::database("main_connection"));

    query.prepare(R"(
        INSERT INTO user_results_raw (
            user_id,
            test_type,
            test_value,
            language,
            speed,
            accuracy,
            consistency,
            created_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'))
    )");

    query.addBindValue(m_userId);
    query.addBindValue(testType);
    query.addBindValue(testDetail.toInt());
    query.addBindValue(language);
    query.addBindValue(speed);
    query.addBindValue(accuracy);
    query.addBindValue(consistency);

    if (!query.exec()) {
        qWarning() << "Ошибка при сохранении теста:" << query.lastError().text();
    }
    query.prepare(R"(UPDATE user_results
SET
    speed = (SELECT ROUND(AVG(speed), 2) FROM user_results_raw
             WHERE user_id = :user_id AND test_type = :test_type
               AND test_value = :test_value AND language = :language),
    accuracy = (SELECT ROUND(AVG(accuracy), 2) FROM user_results_raw
                WHERE user_id = :user_id AND test_type = :test_type
                  AND test_value = :test_value AND language = :language),
    consistency = (SELECT ROUND(AVG(consistency), 2) FROM user_results_raw
                   WHERE user_id = :user_id AND test_type = :test_type
                     AND test_value = :test_value AND language = :language),
    maxSpeed = (SELECT MAX(speed) FROM user_results_raw
                WHERE user_id = :user_id AND test_type = :test_type
                  AND test_value = :test_value AND language = :language)
WHERE user_id = :user_id AND test_type = :test_type
  AND test_value = :test_value AND language = :language;)");


    // Привязываем значения по именам параметров:
    query.bindValue(":user_id", m_userId);
    query.bindValue(":test_type", testType);
    query.bindValue(":test_value", testDetail);
    query.bindValue(":language", language);
    if (!query.exec()) {
        qWarning() << "Ошибка при сохранении теста:" << query.lastError().text();
    }
}


QVariantMap UserStatsManager::getAverageTestResult(const QString &testType, const QString &language, int testDetail) const
{
    QVariantMap result;
    QSqlQuery query(QSqlDatabase::database("main_connection"));
    query.prepare(R"(
        SELECT
            speed AS avg_speed,
            accuracy AS avg_accuracy,
            consistency AS avg_consistency,
            maxSpeed
        FROM user_results
        WHERE user_id = ?
          AND test_type = ?
          AND test_value = ?
          AND language = ?
    )");

    query.addBindValue(m_userId);
    query.addBindValue(testType);
    query.addBindValue(QString::number(testDetail));
    query.addBindValue(language);

    if (!query.exec()) {
        qWarning() << "Ошибка выполнения запроса getAverageTestResult:" << query.lastError().text();
        return result;
    }

    if (query.next()) {
        result["speed"] = query.value("avg_speed").toDouble();
        result["accuracy"] = query.value("avg_accuracy").toDouble();
        result["consistency"] = query.value("avg_consistency").toDouble();
        result["maxSpeed"] = query.value("maxSpeed").toDouble();
    }

    return result;
}

void UserStatsManager::saveLessonResult(int lessonId, const QString &language, double speed, double accuracy)
{
    QSqlQuery query(QSqlDatabase::database("main_connection"));
    qDebug() << "Язык: " << language;
    qDebug() << "аккуратность: " << accuracy;
    qDebug() << "скорость: " << speed;
    qDebug() << "айди: " << lessonId;

    QString lessonTable = "UserLessons_" + language.toUpper();
    QString queryStr = QString(
                           "UPDATE %1 SET speed = ?, accuracy = ? WHERE user_id = ? AND lesson_id = ?"
              ).arg(lessonTable);

    query.prepare(queryStr);

    query.addBindValue(speed);
    query.addBindValue(accuracy);
    query.addBindValue(m_userId);
    query.addBindValue(lessonId);

    if (!query.exec()) {
        qWarning() << "Ошибка при обновлении урока:" << query.lastError().text();
    } else {
        qDebug() << "Урок обновлён успешно";
    }
}

QVariantMap UserStatsManager::getLessonResult(int lessonId, const QString &language) const
{
        QVariantMap result;
        QString lessonTable = "UserLessons_" + language;

        QString queryStr = QString(
                               "SELECT speed, accuracy FROM %1 WHERE user_id = ? AND lesson_id = ?"
                               ).arg(lessonTable);

        QSqlQuery query("main_connection");
        query.prepare(queryStr);
        query.addBindValue(m_userId);
        query.addBindValue(lessonId);

        if (!query.exec()) {
            qWarning() << "Ошибка выполнения запроса getLessonResult:" << query.lastError().text();
            return result;
        }

        if (query.next()) {
            result["speed"] = query.value("speed").toDouble();
            result["accuracy"] = query.value("accuracy").toDouble();
        } else {
            qDebug() << "Данные по уроку не найдены.";
        }
        return result;
}

// для Запомнить меня
bool UserStatsManager::findUserIdBySessionId() {
    qDebug() << "(findUserIdSessionId)подключаемся к бд";
    QSqlQuery query(QSqlDatabase::database("main_connection"));

    if (!query.exec("SELECT user_id FROM user_sessions")) {
        qWarning() << "Ошибка нахождения id:" << query.lastError();
        return false;
    }

    if (query.next()) {
        qDebug() << "Все норм, загружаем id:";
        loadFromDatabase(query.value("user_id").toInt());
        return true;
    }
    return false;  // Если не нашли
}

int UserStatsManager::getUserId()
{
    return m_userId;
}

QString UserStatsManager::getRegistrationDate()
{
    QSqlQuery query(QSqlDatabase::database("main_connection"));
    query.prepare("SELECT registration_date FROM user_profiles WHERE user_id = ?");
    query.addBindValue(m_userId);
    if (!query.exec()) {
        qWarning() << "Ошибка выполнения запроса для даты регистрации" << query.lastError().text();
        return "";
    }

    if (query.next()) {
        return query.value("registration_date").toString();
    }
}
