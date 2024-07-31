#charset "us-ascii"
//
// personScopeAction.t
//
#include <adv3.h>
#include <en_us.h>

#include "personScope.h"

class PSTokens: object
	verbToks = nil
	nounToks = nil
	construct(v?, n?) { verbToks = v; nounToks = n; }
;

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

	// Replacement for generic Action.noMatch method.
	// Last case is the stock default.
	// msgObj is the message object used to get the failure message,
	// probably libMessages unless something fancy is happening.
	// actor is the actor trying and failing.
	// txt is the text the parser couldn't resolve into a valid noun
	// phrase.
	// In most cases this will just be whatever the player typed, but
	// when it's a possessive it'll be the name of the possessor (so
	// if the command was >X ALICE'S PEBBLE, txt will be "alice"
	// instead of "alice's pebble", which is where our tale of woe
	// begins.
	noMatch(msgObj, actor, txt) {
		local f0, f1;

		// Given an invalid noun phrase, see if we can recover
		// a full noun phrase from it.  For example if the
		// original command was >X ALICE'S PEBBLE and txt
		// was "alice", then this will get us "alice's pebble".
		// If the command did NOT contain a possessive adjective
		// this will be nil.
		f0 = _psMatchPossessive(txt);

		// Now evaluate txt to see if it's a person not currently
		// in scope.  That is, if txt is "alice", find out if
		// there's anyone named Alice in the world.
		// If there is, their Person instance is the return value.
		// If not, it's nil.
		f1 = checkPersonScope(actor, txt);

		// First case is that the command contains a possessive
		// adjective and the possessor is a Person not currently
		// in scope.  We respond with something like
		// "You don't see Alice's pebble here. "
		if(f0 && f1) {
			msgObj.personalObjectNotHere(actor, f0);
		} else if(f1) {
			// Next case if when we DO NOT have a possessive
			// adjective but the noun phrase DOES refer to
			// a Person not in scope.
			// If the actor already knows the Person,
			// we respond with something like "She isn't here. "
			// and if they don't know the Person we respond
			// with something like "There isn't anyone named
			// Alice here. "
			if(actor.knowsAbout(f1))
				msgObj.personNotHereButKnown(actor, f1);
			else
				msgObj.personNotHere(actor, f1);
		} else {
			// All of that elaborate nonsense was for nothing.
			// We fall back on the default, something like
			// "You see no alice's pebble here. "
			msgObj.noMatchCannotSee(actor, txt);
		}
	}

	// Our bespoke exception handler-ish thing.
	checkPersonScope(actor, txt) {
		local a, lst, m, obj, toks;

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
			x: x.resolveFirstAction(actor, actor) != nil
		});

		// Make sure we still have at least one candidate command.
		if(lst.length < 1)
			return(nil);

		// Sort the alternatives using the standard badness (and
		// so on) ranking behavior.
		m = CommandRanking.sortByRanking(lst, actor, actor);

		// Make sure we have at least one ranked alternative left.
		if((m == nil) || (m.length < 1))
			return(nil);

		// Get the first alternative and try to get the first action
		// for it.
		if((a = m[1].match.resolveFirstAction(actor, actor)) == nil)
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
		a.resolveNouns(actor, actor, new OopsResults(actor, actor));
		if((a.dobjList_ == nil) || (a.dobjList_.length != 1))
			return(nil);

		// Check the direct object to make sure it's a person.
		obj = a.dobjList_[1].obj_;
		if(!obj.ofKind(Person))
			return(nil);

		return(obj);
	}

	// Convenience methods to get the verbs and nouns, respectively.
	_psGetVerb() { return(_psTokenizeOrigText().verbToks); }
	_psGetNoun() { return(_psTokenizeOrigText().nounToks); }

	_psTokenizeOrigText() {
		local i, isNoun, j, match, nounV, toks, v, verbV;

		if(getOriginalAction() != self)
			return(getOriginalAction()._psTokenizeOrigText());
		toks = getPredicate().getOrigTokenList();
		verbV = new Vector();
		nounV = new Vector();
		for(i = 1; i <= toks.length; i++) {
			isNoun = nil;
			predicateNounPhrases.forEach(function(prop) {
				match = self.(prop);
				if(match && (i == match.firstTokenIndex)) {
					v = new Vector(match.lastTokenIndex
						- i);
					for(j = i; j <= match.lastTokenIndex;
						j++) {
						v.append(getTokVal(toks[j]));
					}
					nounV.append(v);
					i = match.lastTokenIndex;
					isNoun = true;
					return;
				}
			});
			if(!isNoun)
				verbV.append(getTokVal(toks[i]));
		}

		return(new PSTokens(verbV, nounV));
	}

	_psPossRexPat = '\'s'
	_psPossRex = nil

	_psMatchPossessive(txt) {
		local i, j, l, r;

		if(_psPossRex == nil)
			_psPossRex = new RexPattern(_psPossRexPat);

		l = _psTokenizeOrigText().nounToks;
		for(i = 1; i <= l.length; i++) {
			if((j = l[i].indexOf(txt)) == nil)
				continue;
			if((j < l[1].length)
				&& (rexMatch(_psPossRex, l[i][j + 1]) != nil)) {
				r = l[i].join(' ');
				r = rexReplace(' ' + _psPossRexPat, r,
					_psPossRexPat);
				return(r);
			}
		}

		return(nil);
	}
;

modify SmellAction
	noMatch(msgObj, actor, txt) {
		msgObj.noMatchNotAware(actor, txt);
	}
;

modify ListenToAction
	noMatch(msgObj, actor, txt) {
		msgObj.noMatchNotAware(actor, txt);
	}
;

modify Actor usePersonScope = nil;
