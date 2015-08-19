OBJS = argsresources.o \
caps.o \
colour.o \
cursor.o \
desktop.o \
dialogs.o \
fullscreen.o \
listen.o \
misc.o \
popup.o \
rfbproto.o \
selection.o \
shm.o \
sockets.o \
tunnel.o \
vncviewer.o \
../libvncauth/vncauth.o \
../libvncauth/d3des.o

tightvncviewer : $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $(OBJS) -lX11 -lXaw6 -ljpeg -lz -lXt -lXmu -lXext -o tightvncviewer

%.o: %.c Makefile
	$(CC) -c $(CFLAGS) -I. -I../include -I../libvncauth/ -o $@ $<
