#include <utils.h>
#include <dwebview.h>
#include <gtk/gtk.h>
#include <gdk/gdk.h>
#include "i18n.h"


int main(int argc, char* argv[])
{
    init_i18n();
    gtk_init(&argc, &argv);

    GtkWidget *w = create_web_container(TRUE, FALSE);
    char* path = get_html_path("dbus_test");
    GtkWidget *webview = d_webview_new_with_uri(path);
    g_free(path);

    gtk_container_add(GTK_CONTAINER(w), GTK_WIDGET(webview));
    gtk_widget_show_all(w);

    g_signal_connect (w , "destroy", G_CALLBACK (gtk_main_quit), NULL);
    gtk_main();
    return 0;
}
