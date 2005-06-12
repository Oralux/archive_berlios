// ----------------------------------------------------------------------------
// yasr.c
// $Id: yasr.c,v 1.6 2005/06/12 20:54:01 gcasse Exp $
// $Author: gcasse $
// Description: Yasr configuration file. 
// $Date: 2005/06/12 20:54:01 $ |
// $Revision: 1.6 $ |
// Copyright (C) 2004, 2005 Gilles Casse (gcasse@oralux.org)
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
// ----------------------------------------------------------------------------

#include <stdio.h>

#include "constants.h"
#include "textToSpeech.h"
#include "yasr.h"

/* < Constants */

#define CONF_FILENAME "/home/knoppix/.yasr.conf" // RAF (GC): take in account another user.
#define USERNAME "knoppix" // RAF (GC): take in account another user.
//#define CONF_FILENAME "/tmp/.yasr.conf" // RAF (GC): take in account another user.
#define TEMP_FILENAME "/tmp/.yasr.tmp"
#define SECTION "[options]"
#define FILTERED_LINE "synthesizer"
#define MAXBUF 1000

/* > */
/* < createConf */

// createConf
// Copy the configuration file to /home/knoppix/.yasr.conf
// This file is customized to take in account:
// - the expected synthesizer
// - the language (for the final dictionnary)
//
static void createConf(char* theFilename, enum language theLanguage)
{
  ENTER("createConf");

  char *aBuffer=(char*)malloc(MAXBUF);

  // Copy the first part of yasr.conf
  sprintf(aBuffer, "cp %s/yasr.conf1 %s", ORALUX_RUNTIME_YASR, theFilename);
  SHOW(aBuffer);
  system(aBuffer);

  // Second part: dictionary, according to the textToSpeech language
  sprintf(aBuffer, "cat %s/yasr-%s.conf2 >> %s", 
	  ORALUX_RUNTIME_YASR, 
	  getStringLanguage(theLanguage), 
	  theFilename);

  SHOW(aBuffer);
  system(aBuffer);
  free(aBuffer);
}

/* > */
/* < getNewSynthesizer */

static char* getNewSynthesizer(enum textToSpeech theTextToSpeech)
{
  ENTER("getNewSynthesizer");
  char* aSynthesizer=NULL;
  switch(theTextToSpeech)
    {
    case TTS_DECtalk:
      aSynthesizer="synthesizer=emacspeak server\nsynthesizer port=|/usr/bin/tcl /usr/share/emacs/site-lisp/emacspeak/servers/dtk-soft";
      break;
      
    case TTS_Cicero:
      aSynthesizer="synthesizer=emacspeak server\nsynthesizer port=|/usr/bin/tcl /usr/share/emacs/site-lisp/emacspeak/servers/cicero";
      break;

    case TTS_ParleMax:
      aSynthesizer="synthesizer=emacspeak server\nsynthesizer port=|maxlect";
      break;
      
    case TTS_Multispeech:
      aSynthesizer="synthesizer=emacspeak server\nsynthesizer port=|/usr/local/lib/multispeech/speech_server";
      break;

#ifdef ORALUXGOLD
    case TTS_ViaVoice:
      aSynthesizer="synthesizer=emacspeak server\nsynthesizer port=|/usr/bin/tcl /usr/share/emacs/site-lisp/emacspeak/servers/outloud";
      break;
#endif

    default :
    case TTS_Flite:
      aSynthesizer="synthesizer=emacspeak server\nsynthesizer port=|/usr/bin/eflite";
      break;
    }
  return aSynthesizer;
}

/* > */
/* < buildConfigurationYasr */

// buildConfigurationYasr
// create or update the Yasr configuration file (/home/knoppix/.yasr.conf)
// This file is customized to take in account:
// - the expected synthesizer
// - the language (for the final dictionnary)
//
void buildConfigurationYasr(struct textToSpeechStruct* theTextToSpeech, int theConfHasBeenUpdated)
{
  ENTER("buildConfigurationYasr");

  // Check if the configuration file exists
  FILE* fconf=fopen(CONF_FILENAME,"r");
  if (fconf==NULL)
    {
      createConf(CONF_FILENAME, theTextToSpeech->myLanguage);
      fconf=fopen(CONF_FILENAME,"r");      
    }
  else if (!theConfHasBeenUpdated)
    {
      return;
    }

  FILE* ftmp=fopen(TEMP_FILENAME,"w+");

  if ((fconf==NULL) || (ftmp==NULL))
    {
      return;
    }

  char *aBuffer=(char*)malloc(MAXBUF);
  
  int aSectionToProcess=0;
  while(fgets(aBuffer, MAXBUF, fconf))
    {
      if (aSectionToProcess)
	{
	  if (strncmp(aBuffer, FILTERED_LINE, sizeof(FILTERED_LINE)-1)!=0)
	    {
	      fprintf(ftmp,"%s",aBuffer);

	      char* aSection=SECTION;
	      if (*aBuffer==*aSection)
		{
		  aSectionToProcess=0; // another section
		}
	    }
	}

      else if (strncmp(aBuffer, SECTION, sizeof(SECTION)-1)==0)
	{
	  aSectionToProcess=1;

	  fprintf(ftmp,"%s",aBuffer);

	  // Adding the new synthesizer
	  fprintf(ftmp,"%s\n", getNewSynthesizer( theTextToSpeech->myIdentifier));
	}

      else
	{
	  fprintf(ftmp,"%s",aBuffer);
	}
    }

  // Copy the temporary file to the configuration file

  fclose(fconf);
  fconf=fopen(CONF_FILENAME,"w");      
  if (fconf==NULL)
    {
      return;
    }

  rewind(ftmp);

  while(fgets(aBuffer, MAXBUF, ftmp))
    {
      fprintf(fconf, "%s", aBuffer);
    }
  fclose(fconf);
  fclose(ftmp);

  free(aBuffer);
}

/* > */
/* < runYasr */
void runYasr( struct textToSpeechStruct* theTextToSpeech, 
	      enum language theMenuLanguage,
	      char* theCommand)
{
  // Select a software synthesizer possibly compliant with the user preferences.
  enum textToSpeech aYasrSynthesizer=TTS_Flite;
  enum language aPossibleLanguage=theMenuLanguage;
  switch (theTextToSpeech->myIdentifier)
    {
    case TTS_Flite:
    case TTS_DECtalk:
    case TTS_Cicero:
    case TTS_ParleMax:
    case TTS_Multispeech:
#ifdef ORALUXGOLD
    case TTS_ViaVoice:
#endif
      aYasrSynthesizer=theTextToSpeech->myIdentifier;
      aPossibleLanguage=theTextToSpeech->myLanguage;
      break;

    default:
      // We select the nearest possible synthesizer according to the language
      switch (theMenuLanguage)
	{
	case French:
	  aYasrSynthesizer=TTS_Cicero;
	  break;
	case English:
	case German:
	case Spanish:
	default:
	  aYasrSynthesizer=TTS_Flite;
	  break;
	}
      break;
    }

  // the LANG and LANGUAGE variables must match the available voice synthesis.
  // RAF (To be updated when Braille only solution will be available).
  char* aLang="en_US";
  char* aLanguage="en";
  char* aBid=NULL;
  getLanguageVariable( aPossibleLanguage,
		       &aBid, &aBid,
		       &aLang, &aLanguage);

  // synthesizer port parameter
  char* aParam=NULL;
  switch( aYasrSynthesizer)
    {
    case TTS_Cicero:
      aParam="|/usr/bin/tcl /usr/share/emacs/site-lisp/emacspeak/servers/cicero";
      break;
    case TTS_DECtalk:
      aParam="|/usr/bin/tcl /usr/share/emacs/site-lisp/emacspeak/servers/dtk-soft";
      break;
#ifdef ORALUXGOLD
    case TTS_ViaVoice:
      aParam="|/usr/bin/tcl /usr/share/emacs/site-lisp/emacspeak/servers/outloud";
      break;
#endif
    case TTS_ParleMax:
      aParam="|/usr/local/bin/maxlect";
      break;
    case TTS_Multispeech:
      aParam="|/usr/local/lib/multispeech/speech_server";
      break;
    case TTS_Flite:
    default:
      aParam="|/usr/bin/eflite";
      break;
    }

    char* aLine=(char *)malloc(BUFSIZE);
    //static char aLine[BUFSIZE];
  snprintf(aLine, BUFSIZE, "export LANG=%s; export LANGUAGE=%s; yasr -s \"emacspeak server\" -p \"%s\" %s",
	   aLang, aLanguage,
	   aParam, 
	   theCommand);
  system(aLine);
    free( aLine);
}

/* > */
