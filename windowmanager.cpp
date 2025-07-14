#include "windowmanager.h"

WindowManager::WindowManager(QObject *parent)
    : QObject(parent)
{}

void WindowManager::setWindow(QQuickWindow *window)
{
    m_window = window;
}

void WindowManager::toggleFullscreen()
{
    if (!m_window) return;

    if (m_window->visibility() == QWindow::FullScreen) {
        m_window->showNormal();
    } else {
    }
}

void WindowManager::setFullscreen(bool fullscreen)
{
    if (!m_window) return;

    if (fullscreen) {
        m_window->showFullScreen();
    } else {
        m_window->showNormal();
    }
}

bool WindowManager::isFullscreen() const
{
    if (!m_window) return false;

    return m_window->visibility() == QWindow::FullScreen;
}
