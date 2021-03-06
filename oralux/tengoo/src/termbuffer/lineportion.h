#ifndef LINEPORTION_H
#define LINEPORTION_H

#include <glib.h>
#include "escape2terminfo.h"

/* < linePortion */
/* 
A line portion describes an horizontal area in the screen.
When a menu is browsed, the selected item and the previously ones are displayed with distinct styles (for example distinct backgrounds).
Two line portions must be particularly managed to distinguish the selected one.
*/
typedef char chartyp; /* TBD: add support for multi-bytes characters */

struct t_linePortion
{
  int myLine; /* Line number */
  int myFirstCol; /* First column of the portion */
  int myLastCol; /* Last column of the portion */
  style myStyle;
  GString* myString;
  GList* myParent; /* helpful to fastly retrieve the list element which is related to this line portion */
};
typedef struct t_linePortion linePortion;

linePortion* createLinePortion (int theLine, int theCol, style* theStyle, chartyp* theString, GList* theParent);
linePortion* createLinePortionDefault();
linePortion* copyLinePortion (linePortion* theLinePortion);
void deleteLinePortion( linePortion* this);

/* > */
/* < linePortionGroup */

/* a "LinePortionGroup" is a list grouping contiguous LinePortions (e.g. a label including a hotkey). 
*/
void deleteLinePortionGroup( GList* this);

#define getLineFromGList(a) (((linePortion*)(a->data))->myLine)
#define getFirstColFromGList(a) (((linePortion*)(a->data))->myFirstCol)
#define getLastColFromGList(a) (((linePortion*)(a->data))->myLastCol)
#define getGStringFromGList(a) (((linePortion*)(a->data))->myString)
#define getStringFromGList(a) (((linePortion*)(a->data))->myString->str)
#define getStringLengthFromGList(a) (((linePortion*)(a->data))->myString->len)
#define getStyleAddressFromGList(a) &(((linePortion*)(a->data))->myStyle)

int getFeaturesLinePortionGroup( GList* this, linePortion* theFeatures);

#define getTerminfoElementLinePortionGroup(theList) (((linePortion*)(theList->data))->myParent)

/* getWordLinePortion returns the wished word (a group line portion) from the initial group line portion.
NULL is returned if no word is found. */
/* Emacs-like word separator */
#define WORD_SEPARATOR " \n\r\t*-_+=/\\<>#$.,;:!?§\"'µ()[]{}@^%"
GList* getWordLinePortion( GList* this);
/* > */

/* 
Local variables:
folded-file: t
folding-internal-margins: nil
*/

#endif
