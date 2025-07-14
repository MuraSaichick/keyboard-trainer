#ifndef WINDOWMANAGER_H
#define WINDOWMANAGER_H

#include <QObject>
#include <QQuickWindow>

class WindowManager : public QObject
{
    Q_OBJECT
public:
    explicit WindowManager(QObject *parent = nullptr);

    void setWindow(QQuickWindow *window);

    Q_INVOKABLE void toggleFullscreen();
    Q_INVOKABLE void setFullscreen(bool fullscreen);
    Q_INVOKABLE bool isFullscreen() const;

private:
    QQuickWindow *m_window = nullptr;
};

#endif // WINDOWMANAGER_H
