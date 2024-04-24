#charset "us-ascii"
//
// personScope.t
//
//	A TADS3/adv3 module for handling failure messages for actions
//	referring to characters not in scope.
//
//	Specifically, if there's a character named Alice in the game, then
//	if the player tries to interact with her when she's not in the
//	room instead of getting:
//
//		>X ALICE
//		You see no alice here.
//
//	...they'll get (by default)...
//
//		>X ALICE
//		There isn't anyone named Alice here.
//
//	That's the default if the player hasn't met Alice yet.  If they have
//	met Alice, then they'll get:
//
//		>X ALICE
//		She isn't here.
//
//	These messages are personNotHere and personNotHereButKnown in
//	libMessages (defined in personScopeMsg.t), and can be overridden
//	in the standard ways.
//
//
#include <adv3.h>
#include <en_us.h>

#include "personScope.h"

// Module ID for the library
personScopeModuleID: ModuleID {
        name = 'Person Scope Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}
