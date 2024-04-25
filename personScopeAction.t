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

// Here we try to intercept a parse failure to see if the reason why the
// failure is happening is that the command mentions an out-of-scope person.
//
// This is specifically to handle situations like >ALICE, [some command],
// where the failure is NOT going to be during "normal" noun resolution (like
// the cases we handle above) but instead inside a special case in the
// parser's inner loop where it handles commands directed at another actor.
// If we weren't doing anything, cases where resolution of the actor
// receiving the command fails are normally handled by the parser throwing
// an exception which is the actor issuing the command receives as a
// notification.
//
// What we do here is insert ourselves into the bit where the problem
// is being noted, before any exception is thrown.  
modify ActorResolveResults
	// This is what will be called in the normal course of things
	// if the player tries something like >ALICE, TAKE PEBBLE and
	// there's nobody named Alice in scope.
	noVocabMatch(action, txt) {
		// See if we want to handle it instead.
		if(tryPersonScope(action, txt))
			return;

		// Fall through.  This will end up with the parser
		// throwing an exception which will in turn call
		// gActor.notifyParseFailure() to report the failure.
		inherited(action, txt);
	}

	// Our bespoke exception handler-ish thing.
	tryPersonScope(action, txt) {
		local a, lst, m, obj, prop, toks;

		// The txt arg will contain the bit of the command string
		// that looks like a noun phrase that didn't match anything.
		// So in the case of >ALICE, TAKE PEBBLE this would be "ALICE".
		// What we do here is tokenize a command string that's
		// "X " plus the un-matched noun phrase, "ALICE" in our
		// example.
		// That is, we're creating a command where we're
		// trying to >EXAMINE the name of whatever cause parsing
		// to fail.  Specifically so we can twiddle the scope and
		// see if it succeeds and resolves to a person.
		if((toks = cmdTokenizer.tokenize('x <<txt>>')) == nil)
			return(nil);

		// Now try to parse the token list we generated above.
		// This returns a list of alternatives to how the command
		// could be parsed, hopefully, per the command dictionary.
		if((lst = firstCommandPhrase.parseTokens(toks, cmdDict)) == nil)
			return(nil);

		// Prune the command alteratives to eliminate ones that
		// don't yield valid actions.  This usually doesn't do much
		// in English, and we're only doing it here because we're
		// mirroring the parser's inner loop.
		lst = lst.subset({
			x: x.resolveFirstAction(gActor, gActor) != nil
		});

		// Make sure we have at least one valid command alternative.
		if(lst.length < 1)
			return(nil);

		// Rank our results.
		m = CommandRanking.sortByRanking(lst, gActor, gActor);
		if((m == nil) || (m.length < 1))
			return(nil);
		
		// Get the first action in the top result.
		if((a = m[1].match.resolveFirstAction(gActor, gActor)) == nil)
			return(nil);

		// Tell the action to use the extended person scope.
		a.usePersonScope = true;

		// Try noun resolution.
		a.resolveNouns(gActor, gActor, new OopsResults(gActor, gActor));

		// If that didn't work, give up.
		if((a.dobjList_ == nil) || (a.dobjList_.length != 1))
			return(nil);

		// Make sure noun resolution matched a person.
		obj = a.dobjList_[1].obj_;
		if(!obj.ofKind(Person))
			return(nil);

		// Okay, cool.  We've determined that the noun phrase that
		// failed (the reason we're here in the first place) succeeds
		// if we put all Person instances in scope, so the noun
		// phrase must refer to an out-of-scope person.  Output
		// our custom failure messages for that case and then exit.
		if(gActor.knowsAbout(obj))
			prop = &personNotHereButKnown;
		else
			prop = &personNotHere;

		gActor.notifyParseFailure(gActor, prop, obj);
		exit;
	}
;
