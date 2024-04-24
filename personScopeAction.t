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

	// Check to see if the given object is a) a person, b) the action
	// is checking the extended person scope, and c) if the actor taking
	// the action wants the extened person scope.
	checkPersonScopeFlag(obj) {
		return((obj != nil) && obj.ofKind(Person)
			&& (usePersonScope == true)
			&& (gActor.usePersonScope == true));
	}

	// Called when we fail noun resolution.  We handle this by (possibly)
	// checking again with the extended person scope.
	noMatch(msgObj, actor, txt) {
		// First we check to see if this is something we want to
		// resolve.
		if(tryPersonScope(msgObj, actor, txt))
			return;

		// Nope, handle normally.
		inherited(msgObj, actor, txt);
	}

	// See if we want to try to handle this via the person scope and,
	// if so, if that works.
	tryPersonScope(msgObj, actor, txt) {
		local obj;

		// Mark the scope flag on this action.
		usePersonScope = true;

		// Try noun resolution again with the scope flag.
		resolveNouns(gIssuingActor, gActor,
			new OopsResults(gIssuingActor, gActor));
		
		// If we still don't have any object matches, give up.
		// Specifically we want EXACTLY ONE match.  If adding
		// multiple people to the scope results in multiple matches
		// we don't want to pester the player with a disambig
		// prompt just to give a slightly different failure
		// message, so we just live with the library default.
		if((dobjList_ == nil) || (dobjList_.length != 1))
			return(nil);

		// If we have exactly one match, make sure it's a person.
		obj = dobjList_[1].obj_;
		if(!obj.ofKind(Person))
			return(nil);

		// Actually do the custom message reporting.
		if(gActor.knowsAbout(obj))
			msgObj.personNotHereButKnown(actor, obj);
		else
			msgObj.personNotHere(actor, obj);

		// Done.
		return(true);
	}
;

modify Actor usePersonScope = nil;

// Replacements for SmellAction and ListenToAction, which are the
// two places adv3 overrides Action.noMatch().
replace VerbRule(Smell)
	( 'smell' | 'sniff' ) dobjList
	: SmellAction
	verbPhrase = 'smell/smelling (what)'
	noMatch(msgObj, actor, txt) {
		if(tryPersonScope(msgObj, actor, txt))
			return;
		msgObj.noMatchNotAware(actor, txt);
	}
;

replace VerbRule(ListenTo)
	( 'hear' | 'listen' 'to' ) dobjList
	: ListenToAction
	verbPhrase = 'listen/listening (to what)'
	noMatch(msgObj, actor, txt) {
		if(tryPersonScope(msgObj, actor, txt))
			return;
		msgObj.noMatchNotAware(actor, txt);
	}
;
