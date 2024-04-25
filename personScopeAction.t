#charset "us-ascii"
//
// personScopeAction.t
//
#include <adv3.h>
#include <en_us.h>

#include "personScope.h"

modify Action
	// Flag on action to include Person instances in scope.
	usePersonScope = nil

	// Check to see if the object is in scope.
	objInScope(obj) {
		// Check to see if we're just "normally" in scope.  If
		// so, we have nothing else to do.
		if(inherited(obj) == true)
			return(true);

		// See if the object is in the extended person scope.
		return(checkPersonScopeFlag(obj));
	}

	// Check to see if the given object is a) a person, b) has
	// a proper name, c) the action is configured to check the extended
	// person scope, and d) if the actor taking the action wants the
	// extened person scope.
	checkPersonScopeFlag(obj) {
		return((obj != nil) && obj.ofKind(Person)
			&& (obj.isProperName == true)
			&& (usePersonScope == true)
			&& (gActor.usePersonScope == true));
	}
;

modify Actor usePersonScope = nil;
