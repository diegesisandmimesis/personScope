#charset "us-ascii"
//
// personScopeMsg.t
//
#include <adv3.h>
#include <en_us.h>

#include "personScope.h"

modify libMessages
	personNotHere(actor, person) {
		gMessageParams(person);
		"There {is person}n't anyone named {you person/him} {|t}here. ";
	}
	personNotHereButKnown(actor, person) {
		gMessageParams(person);
		"{That person/He} {is person}n't {|t}here. ";
	}
	personalObjectNotHere(actor, txt) {
		"{You/He} {do}n't see \^<<txt>> {|t}here. ";
	}
;
