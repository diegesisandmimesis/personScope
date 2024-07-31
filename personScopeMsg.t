#charset "us-ascii"
//
// personScopeMsg.t
//
#include <adv3.h>
#include <en_us.h>

#include "personScope.h"

modify libMessages
	// Generic "that person isn't here" message method.  This handles
	// the logic of figureing out whether or not the actor taking the
	// action knows the out-of-scope person or not.
	personNotHere(actor, person) {
		if(actor.knowsAbout(person))
			personNotHereButKnown(actor, person);
		else
			personNotHereAndUnknown(actor, person);
	}

	// Alice isn't here and we've never met her.
	personNotHereAndUnknown(actor, person) {
		gMessageParams(person);
		"There {is person}n't anyone named {you person/him} {|t}here. ";
	}

	// We know Alice, but she's not here right now.
	personNotHereButKnown(actor, person) {
		gMessageParams(person);
		"{That person/He} {is person}n't {|t}here. ";
	}

	// We tried looking at Alice's pebble, but we don't see it here.
	personalObjectNotHere(actor, txt) {
		"{You/He} {do}n't see \^<<txt>> {|t}here. ";
	}
;

// Tweak for weirdness in adv3.
// By default if you use a possessive adjective in a noun phrase and there's
// no matching object in scope (>X ALICE'S PEBBLE) you get a report
// about the owner ("You see no alice here.").  We deal with that elsewhere.
// But adv3 has the additional weirdness of responding to >X ALICE'S PEBBLE,
// if there's no matching object in scope and Alice is also out of scope,
// with "Alice does not appear to have any such thing" (which is also
// what it says if Alice is in scope).
// This changes the behavior to be the same we use for out-of-scope
// possessives in general ("You don't see Alice's pebble here").
modify playerMessages
	noMatchForPossessive(actor, owner, txt) {
		if(actor.scopeList().indexOf(owner) == nil)
			personalObjectNotHere(actor,
				owner.theNamePossAdj + ' ' + txt);
		else
			inherited(actor, owner, txt);
	}
;
