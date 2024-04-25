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

modify playerMessages
	noMatch(actor, action, txt) {
		if(tryPersonScope(actor, action, txt))
			return;
		inherited(actor, action, txt);
	}

	// Our bespoke exception handler-ish thing.
	tryPersonScope(actor, action, txt) {
		local a, lst, m, obj, prop, toks;

		// The txt arg will contain the bit of the command string
		// that looks like a noun phrase but didn't match anything.
		// We use that to build an arbitrary-ish command in which
		// it is the only noun phrase.
		// So if the original (player-supplied) command was
		// something like >ALICE, TAKE PEBBLE then we'll get
		// "ALICE" and build the command >X ALICE from it.
		// We then try to do normal-ish parsing of the command.
		// The first step is to tokenize the new command string.
		if((toks = cmdTokenizer.tokenize('x <<txt>>')) == nil)
			return(nil);

		// Now we try parse the tokens we got above, producing a
		// list of command alternatives.
		if((lst = firstCommandPhrase.parseTokens(toks, cmdDict)) == nil)
			return(nil);

		// We prune the results, removing any that don't make sense.
		// In English this usually doesn't do much, but we're
		// just mirroring the parser's behavior here.
		lst = lst.subset({
			x: x.resolveFirstAction(gActor, gActor) != nil
		});

		// Make sure we still have at least one candidate command.
		if(lst.length < 1)
			return(nil);

		// Sort the alternatives using the standard badness (and
		// so on) ranking behavior.
		m = CommandRanking.sortByRanking(lst, gActor, gActor);

		// Make sure we have at least one ranked alternative left.
		if((m == nil) || (m.length < 1))
			return(nil);

		// Get the first alternative and try to get the first action
		// for it.
		if((a = m[1].match.resolveFirstAction(gActor, gActor)) == nil)
			return(nil);

		// We tell the resolved action to use the extended person
		// scope.
		a.usePersonScope = true;

		// Now we get the action to do noun resolution.  There
		// should be only one direct object in here (due to how
		// we constructed the command string).
		// If we somehow or other got multiples (like if we added
		// all Person instances to the scope and suddenly >X ALICE
		// is ambiguous because there are multiple Alices) we
		// just give up and live with the default failure mode
		// because we don't want to give the player a disambig prompt
		// just to hand them a failure message either way.
		a.resolveNouns(gActor, gActor, new OopsResults(gActor, gActor));
		if((a.dobjList_ == nil) || (a.dobjList_.length != 1))
			return(nil);

		// Check the direct object to make sure it's a person.
		obj = a.dobjList_[1].obj_;
		if(!obj.ofKind(Person))
			return(nil);

		// Hurray, we know what's going on.  Figure out what
		// error message to use.
		if(gActor.knowsAbout(obj))
			prop = &personNotHereButKnown;
		else
			prop = &personNotHere;

		// Notify the actor of the failure.
		actor.notifyParseFailure(gActor, prop, obj);
		exit;
	}
;
