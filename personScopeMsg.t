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
		"There {is person}n't anyone named {you person/him} here. ";
	}
	personNotHereButKnown(actor, person) {
		gMessageParams(person);
		"{That person/He} {is person}n't here. ";
	}
;
