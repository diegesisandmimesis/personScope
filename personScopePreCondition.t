#charset "us-ascii"
//
// personScopePreCondition.t
//
#include <adv3.h>
#include <en_us.h>

#include "personScope.h"

/*
modify PreCondition
	verifyPersonScope(obj) {
		if((obj == nil) || !obj.ofKind(Person))
			return(nil);
		if(gActor.usePersonScope != true)
			return(nil);
		if(gActor.knowsAbout(obj) == nil)
			return(&personNotHere);
		else
			return(&personNotHereButKnown);
	}

	verifyPersonScopePreCondition(obj, fn) {
		local prop;

		if(((prop = verifyPersonScope(obj)) == nil) || (fn)(obj))
			return;

		inaccessible(prop);
	}
	checkPersonScopePreCondition(obj, allowImplicit, fn) {
		local prop;

		if(((prop = verifyPersonScope(obj)) == nil) || (fn)(obj))
			return;

		reportFailure(prop);
		exit;
	}
;

modify objVisible
	verifyPreCondition(obj) {
		verifyPersonScopePreCondition(obj, function(obj) {
			return(gActor.canSee(obj));
		});
		inherited(obj);
	}
;

modify objAudible
	verifyPreCondition(obj) {
		verifyPersonScopePreCondition(obj, function(obj) {
			return(gActor.canHear(obj));
		});
		inherited(obj);
	}
;

modify canTalkToObj
	checkPreCondition(obj, allowImplicit) {
		checkPersonScopePreCondition(obj, allowImplicit, function(obj) {
			return(gActor.canTalkTo(obj));
		});
		inherited(obj, allowImplicit);
	}
;
*/
