/********************************************************************
 * Copyright (C) 2014 by Verimag                                    *
 * Initial author: Matthieu Moy                                     *
 ********************************************************************/

#include <X11/Xlib.h>
#include <X11/Xutil.h>

int main() {
	XOpenDisplay(NULL);
	return 0;
}
