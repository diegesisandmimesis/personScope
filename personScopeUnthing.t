#charset "us-ascii"
//
// personScopeUnthing.t
//
#include <adv3.h>
#include <en_us.h>

#include "personScope.h"

// Abstract class intended to make it ever so slightly easier to declare
// placeholders for non-NPC people mentioned in the game.  If your game
// mentions, for example, Socrates as a historical figure but Socrates is
// not a character in the game, doing something like:
//
//	PersonScopeUnthing 'Socrates';
//
// ...then you get...
//
//	>X SOCRATES
//	There isn't anyone named Socrates here.
//
// ...instead of...
//
//	>X SOCRATES
//	You see no socrates here.
//
// ...or..
//
//	>X SOCRATES
//	The word "socrates" is not necessary in this story.
//
// ...depending on the vocabulary of the rest of the game objects.
class PersonScopeUnthing: Person, Unthing
	isProperName = true
	initializeThing() {
		inherited();
		if((name != nil) && (vocabWords == '')) {
			vocabWords = name;
			initializeVocab();
			addToDictionary(&noun);
		}
	}
;
