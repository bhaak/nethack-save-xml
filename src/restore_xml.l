%{
#include "hack.h"
#include "save_xml.h"
#include "restore_xml.h"


%}

%option nounput
%s TAG ENDTAG ELEMENT VAL_TAG VAL_TYPE STRUCT_TAG STRUCT_TYPE GLYPH_TAG GLYPH_TYPE
%%
<INITIAL,ELEMENT>\<			{BEGIN(TAG);		return '<';}
<TAG,VAL_TAG,STRUCT_TAG,GLYPH_TAG>>	{BEGIN(ELEMENT);	return '>';}
<VAL_TYPE,STRUCT_TYPE,GLYPH_TYPE>>	{BEGIN(ELEMENT);	return '>';}
<ENDTAG>>				{BEGIN(INITIAL);	return '>';}
<TAG>\/					{BEGIN(ENDTAG);		return '/';}

<TAG,VAL_TAG,STRUCT_TAG,GLYPH_TAG>=	return '=';
<VAL_TYPE,STRUCT_TYPE,GLYPH_TYPE>=	return '=';
<TAG>,					return ',';

<TAG,ENDTAG>ARRAY			return ARRAY;
<TAG,ENDTAG>STRUCT			{BEGIN(STRUCT_TAG); return STRUCT;}


<TAG,ENDTAG>RM_BACKGROUND		return RM_BACKGROUND;
<TAG,ENDTAG>RM_REGION			return RM_REGION;
<TAG,ENDTAG>RM_POINTER			return RM_POINTER;

<TAG,ENDTAG>COMMENT			return COMMENT;

<TAG,ENDTAG>ARTIFACT			return ARTIFACT;
<TAG,ENDTAG>ARTIFACTS			return ARTIFACTS;
<TAG,ENDTAG>BONEDATA			return BONEDATA;
<TAG,ENDTAG>BRANCHES			return BRANCHES;
<TAG,ENDTAG>BUBBLES			return BUBBLES;
<TAG,ENDTAG>CMAP			return CMAP;
<TAG,ENDTAG>CONTENTS			return CONTENTS;
<TAG,ENDTAG>CURRENT_STAT		return CURRENT_STAT;
<TAG,ENDTAG>DAMAGES			return DAMAGES;
<TAG,ENDTAG>DUNGEON			return DUNGEON;
<TAG,ENDTAG>DUNGEON_OVERVIEW		return DUNGEON_OVERVIEW;
<TAG,ENDTAG>ENGRAVINGS			return ENGRAVINGS;
<TAG,ENDTAG>FLOOR			return FLOOR;
<TAG,ENDTAG>FRUITS			return FRUITS;
<TAG,ENDTAG>GAMESTAT			return GAMESTAT;
<TAG,ENDTAG>GLYPH			{BEGIN(GLYPH_TAG); return GLYPH;}
<TAG,ENDTAG>LAUNCH			return LAUNCH;
<TAG,ENDTAG>LEVCHN			return LEVCHN;
<TAG,ENDTAG>LEVELDATA			return LEVELDATA;
<TAG,ENDTAG>LEVELS			return LEVELS;
<TAG,ENDTAG>LIGHT_SOURCES		return LIGHT_SOURCES;
<TAG,ENDTAG>MONSTER			return MONSTER;
<TAG,ENDTAG>MONSTERS			return MONSTERS;
<TAG,ENDTAG>MON_EXTRA_DATA		return MON_EXTRA_DATA;
<TAG,ENDTAG>OBJECT			return OBJECT;
<TAG,ENDTAG>OBJECTS			return OBJECTS;
<TAG,ENDTAG>OBJECT_CLASS		return OBJECT_CLASS;
<TAG,ENDTAG>OBJECT_CLASSES		return OBJECT_CLASSES;
<TAG,ENDTAG>OBJ_ATTACHED		return OBJ_ATTACHED;
<TAG,ENDTAG>ORACLES			return ORACLES;
<TAG,ENDTAG>PROPERTY			return PROPERTY;
<TAG,ENDTAG>REGIONS			return REGIONS;
<TAG,ENDTAG>RM_TYPE			return RM_TYPE;
<TAG,ENDTAG>ROOM			return ROOM_DATA;
<TAG,ENDTAG>SUBROOM			return SUBROOM;
<TAG,ENDTAG>SAVEDATA			return SAVEDATA;
<TAG,ENDTAG>SPELL_BOOK			return SPELL_BOOK;
<TAG,ENDTAG>TIMER			return TIMER;
<TAG,ENDTAG>TIMERS			return TIMERS;
<TAG,ENDTAG>TRAPS			return TRAPS;
<TAG,ENDTAG>VERSION			return VERSION;
<TAG,ENDTAG>WATERLEBEL			return WATERLEBEL;
<TAG,ENDTAG>WORM			return WORM;
<TAG,ENDTAG>WORMS			return WORMS;
<TAG,ENDTAG>WORM_SEGMENT		return WORM_SEGMENT;

<TAG,ENDTAG>OBJ_NAME			return OBJECT_NAME;
<TAG,ENDTAG>OBJ_UNKNOWN_NAME		return OBJ_UNKNOWN_NAME;
<TAG,ENDTAG>OBJCLASS			return OBJCLASS;
<TAG,ENDTAG>MONS_NAME			return MONS_NAME;

<TAG,ENDTAG>ROLE			return ROLE;
<TAG,ENDTAG>RACE			return RACE;
<TAG,ENDTAG>GENDER			return GENDER;
<TAG,ENDTAG>ALIGN			return ALIGN;
<TAG,ENDTAG>QUEST			return QUEST;

<TAG,ENDTAG>BITFIELDS			return BIT_FIELD;
<TAG,ENDTAG>BOOL			return BOOL;
<TAG,ENDTAG>VAL				{BEGIN(VAL_TAG); return VAL;}
<TAG,ENDTAG>STRING			return STRING;

<TAG,VAL_TAG,STRUCT_TAG>id		return ID;
<TAG>num				return NUM;
<TAG>type				return TYPE;
<VAL_TAG>type				{BEGIN(VAL_TYPE); return TYPE;}
<STRUCT_TAG>type			{BEGIN(STRUCT_TYPE); return TYPE;}
<GLYPH_TAG>type				{BEGIN(GLYPH_TYPE); return TYPE;}
<TAG>wgrowtime				return WGROWTIME;
<TAG>class				return CLASS;
<TAG>bits				return BITS;
<TAG>size				return F_SIZE;
<TAG>index				return INDEX;
<TAG>region				return REGION_PARM;

<VAL_TYPE>\"char\"			{BEGIN(TAG); return CHAR;	}
<VAL_TYPE>\"schar\"			{BEGIN(TAG); return SCHAR;	}
<VAL_TYPE>\"uchar\"			{BEGIN(TAG); return UCHAR;	}
<VAL_TYPE>\"int\"			{BEGIN(TAG); return INT;	}
<VAL_TYPE>\"uint\"			{BEGIN(TAG); return UINT;	}
<VAL_TYPE>\"short\"			{BEGIN(TAG); return SHORT;	}
<VAL_TYPE>\"ushort\"			{BEGIN(TAG); return USHORT;	}
<VAL_TYPE>\"long\"			{BEGIN(TAG); return LONG;	}
<VAL_TYPE>\"ulong\"			{BEGIN(TAG); return ULONG;	}
<VAL_TYPE>\"time_t\"			{BEGIN(TAG); return TIME_T;	}
<VAL_TYPE>\"[^"]*\"			{BEGIN(TAG); return UNKNOWN;	}

<GLYPH_TYPE>\"invalid\"			{BEGIN(TAG); return GLYPH_INVALID;	}
<GLYPH_TYPE>\"warning\"			{BEGIN(TAG); return GLYPH_WARNING;	}
<GLYPH_TYPE>\"swallow\ border\"		{BEGIN(TAG); return GLYPH_SWALLOW;	}
<GLYPH_TYPE>\"zap\ beam\"		{BEGIN(TAG); return GLYPH_ZAP;		}
<GLYPH_TYPE>\"explosion\"		{BEGIN(TAG); return GLYPH_EXPLOSION;	}
<GLYPH_TYPE>\"cmap\"			{BEGIN(TAG); return GLYPH_CMAP;		}
<GLYPH_TYPE>\"object\"			{BEGIN(TAG); return GLYPH_OBJECT;	}
<GLYPH_TYPE>\"ridden\ mon\"		{BEGIN(TAG); return GLYPH_RIDDEN;	}
<GLYPH_TYPE>\"corpse\"			{BEGIN(TAG); return GLYPH_CORPSE;	}
<GLYPH_TYPE>\"detected\ mon\"		{BEGIN(TAG); return GLYPH_DETECTED;	}
<GLYPH_TYPE>\"invisible\ mon\"		{BEGIN(TAG); return GLYPH_INVIS_MON;	}
<GLYPH_TYPE>\"pet\"			{BEGIN(TAG); return GLYPH_PET;		}
<GLYPH_TYPE>\"monster\"			{BEGIN(TAG); return GLYPH_MONST;	}
<GLYPH_TYPE>\"[^"]*\"			{BEGIN(TAG); return UNKNOWN;		}

<STRUCT_TYPE>\"[^"]+\"			{
						char *ptr = unescape_string(yytext, TRUE);
						int len;

						/* remove first and last '"' */
						ptr++;
						len = strlen(ptr);
						ptr[len-1] = 0;

						BEGIN(TAG);
						yylval.i = serach_struct_id(ptr);
						return STRUCT_ID;
					}

<TAG>[+\-]?[0-9]+			|
<TAG>0x[0-9a-fA-F]+			{
						yylval.i = strtol(yytext, NULL, 0);
						return NUMBER_DATA;
					}

<TAG>\"[^"]*\"				|
<VAL_TAG,STRUCT_TAG,GLYPH_TAG>\"[^"]*\"	{
						yylval.string = unescape_string(yytext, TRUE);
						return STRING_DATA;
					}

<TAG>\n|[ \t]+				|
<VAL_TAG,STRUCT_TAG,GLYPH_TAG>\n|[ \t]+	|
<VAL_TYPE,STRUCT_TYPE>\n|[ \t]+		|
<GLYPH_TYPE>\n|[ \t]+			;

<TAG,ENDTAG>[a-zA-Z_][a-zA-Z_0-9]*	return UNKNOWN_TAG;

<ELEMENT>[^<\n]+			{
						yylval.string = unescape_string(yytext, TRUE);
						return DATA;
					}

\n					;
\r					;

.					return UNKNOWN_DATA;

%%

int
yywrap()
{
    return 1;
}
