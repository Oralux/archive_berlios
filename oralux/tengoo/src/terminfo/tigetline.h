#ifndef TIGETLINE_H
#define TIGETLINE_H

#include "terminfo2list.h"

/* < terminfoGetLinePortionAtCursor */
/* 
Search the not blanked line portion after the cursor.
The related list element is returned or NULL otherwise.
theTermAPI supplies several handlers to collect terminal info.
*/

GList* terminfoGetLinePortionAtCursor(GList* theTerminfoList, cursor* theCursor);
/* > */

/* < terminfoExpandText */
/*
terminfoExpandText implements a general policy for saying the relevant chunk of text after a cursor displacement.
For example, according to this displacement, the whole line or just a word could be said.
The chunk of text is prepended to the list and the new list pointer is updated.
Input:
theFirstCursor: cursor pos before applying the terminfo sequence.
theLastCursor: cursor pos after applying the terminfo sequence.
1 is returned if text has been expanded, 0 otherwise.
*/
int terminfoExpandText(GList** theTerminfoList, termAPI* theTermAPI, cursor* theFirstCursor, cursor* theLastCursor);
/* > */

/* < terminfoVocalStyle */
/* indicate the wished voice (from SGR) in adding TSAR sequences */
void terminfoVocalStyle( GList** theTerminfoList);
/* > */

#endif
