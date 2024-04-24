#charset "us-ascii"
//
// sample.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the personScope library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f makefile.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

#include "personScope.h"

versionInfo: GameID;
gameMain: GameMainDef initialPlayerChar = me;

middleRoom: Room 'Middle Room'
	"This is the middle room.  There are rooms north and south of here. "
	north = northRoom
	south = southRoom
;
+me: Person
	usePersonScope = true
;
+pebble: Thing '(small) (round) pebble' 'pebble' "A small, round pebble. ";

northRoom: Room 'North Room'
	"This is the north room.  There's another room to the south. "
	south = middleRoom
;
+alice: Person 'alice' 'Alice'
	"She looks like the first person you'd turn to in a problem. "
	isHer = true
	isProperName = true
;

southRoom: Room 'South Room'
	"This is the south room.  There's another room to the north. "
	north = middleRoom
;
+bob: Person 'bob' 'Bob'
	"He looks like Robert, only shorter. "
	isHim = true
	isProperName = true
;
