Object subclass: #AbstractObject
	"Answers the object's given name."
	^ uiName! !
	"Sets the object's given name to the argument. Type-checking is deliberately omitted, to allow for pretty-printing and generalization of user interface to implmentation via other abstract objects."
	uiName _ aString! !
In the actual implementation, however, references are abstracted as Reference objects, which are containers for the actual references.  This allows self-reference by arrows and reference on a graph that contains the particular arrow without causing the VM to go into an infinite recursion.!
	"Answers the reference indexed by the argument. This supports the generalization to multi-arrows."
	anInteger == 0 ifTrue: [^ tail foo].
	anInteger == 1 ifTrue: [^ head foo].
	self halt: 'Arrows only have slots indexed 0 and 1.'! !
	"Changes the indexed reference to the argument. Type-checking performed by head: and tail:."
	anInteger == 0
		ifTrue: [self tail: anArrow]
		ifFalse: [anInteger == 1
				ifTrue: [self head: anArrow]
				ifFalse: [self halt: 'Arrows only have slots indexed 0 and 1.']]! !
	"Answers the second reference."
	^ head foo! !
	"Changes the second reference to the argument."
	|newReference|
	(anArrow isKindOf: Arrow)
		ifFalse: [self error: 'Arrows may only reference other arrows.'].
	newReference _ Reference new.
	newReference store: anArrow.
	head _ newReference! !
	"Sets both references."
	self head: anArrow1.
	self tail: anArrow2! !
	"Set the receiver's references and given name."
	self head: anArrow1.
	self tail: anArrow2.
	self uiName: aString
! !
	"Answers the first reference."
	^ tail foo! !
	"Changes the first reference to the argument."
	|newReference|
	(anArrow isKindOf: Arrow)
		ifFalse: [self error: 'Arrows may only reference other arrows.'].
	newReference _ Reference new.
	newReference store: anArrow.
	tail _ newReference! !
	"Answers the arrow composition of two arrows, the receiver being the second arrow in the sequence and the argument the first."
	(anArrow isKindOf: Arrow)
		ifFalse: [^ self].
	self tail == anArrow head ifTrue: [^ Arrow new head: (self head) tail: (anArrow tail)]! !
	"Answers a new arrow with transposed references."
	^ Arrow new head: (self tail) tail: (self head)! !
	"Initialize the receiver to empty references, referencing the ArrowWorld constant NulArrow."
	self head: nil tail: nil uiName: (String new)
! !
	"Tests for extensional equality. That is, equality via comparing the object's variables. Translates to Arrow system equality within square and relativised square frames.  Intensional equality is purely reflexive."
	(anArrow isKindOf: Arrow)
		ifFalse: [^false].
	self head = anArrow head ifTrue: [^self tail = anArrow tail].
	^false! !
	"Answers whether or not the receiver points to the argument."
	^ (self head == anArrow) | (self tail == anArrow)! !
	"Syntactic sugar."
	^ self isCompositionOf: anArrow1 with: anArrow2! !
	"Answers whether the receiver is a valid composition result of the arguments in either order."
	^ self == (anArrow1 compose: anArrow2) | self == (anArrow2 compose: anArrow1)! !
	"Answers whether the receiver's references are identical. Identity arrows represent nul information transitions."
	^ (self head == self tail)! !
	"Answers whether the receiver is a valid inverse of the argument."
	^ self head == (anArrow tail) & (self tail == (anArrow head)).! !
	"Create a new arrow and initialize it."
	^ super new initialize.! !
Each graph represents a (possibly reflective) relation, providing the fundamental constraint construct for specification.  Graphs are relative, in that they only represent the resulting relation computed by a declarative inference scheme.  In this way, ArrowGraphs are an implementational hack, in that they encode the information of the arrows they replace.!
	^ cache! !
	"Sets the cache to a known set.  Type-checking is not implemented yet."
	cache _ aSet! !
	"Returns the intensional meaning of the receiver."
	^ intension! !
	"Sets the graph's intensional meaning to anArrow."
	intension _ anArrow! !
	"Answers the given name of the graph."
	^ uiName! !
	"Sets the given name of the graph. Type-checking is deliberately omitted to allow for pretty-printing and generalizing user interface to include implementation via arrows."
	uiName _ aString! !
	"Modifies the cache of the graph to include the argument as well.  The argument must satisfy the receiver's intension. Provide the proof incrementally and intensionally."
	anArrow isNil ifTrue: [self error: 'ArrowGraphs cannot meaningfully contain nil as an element'].
	(anArrow isKindOf: Arrow)
		ifFalse: [self error: 'ArrowGraphs can only contain arrows'].
	"Implement here the intension type check."
	cache ifNil: [cache _ Set new].
	cache add: anArrow! !
	"Answers whether the receiver contains arrows which reference any arrows from the argument."

	(cache isEmpty) | (anArrowGraph cache isEmpty) ifTrue: [^ false].
	cache size ~~ (anArrowGraph cache size) ifTrue: [^ false].
	cache do: [:element | element == nil
			ifFalse: [
				[(anArrowGraph includes: [element tail])
					| (anArrowGraph includes: [element head]) ifTrue: [^ true]]
					value: element]].
	^ false! !
	"Answers whether the argument contains all of the receiver's arrows. The implementation so far is only extensional."
	self extensional ifTrue: [(cache size > anArrowGraph cache size)
		ifTrue: [^false]].
	(cache isEmpty) | (anArrowGraph cache isEmpty) ifTrue: [^ true].
	(cache do: [:eachArrow | (anArrowGraph includes: eachArrow)
		ifFalse: [^false]]).
	^ true! !
	^ anArrowGraph isSubGraphOf: self! !
	"Sets up the receiver for default behavior."
	cache _ Set new. "Probably obsolete, but not unsafe."
	self uiName: 'New Arrow Graph'.
	self setIntensional! !
	"Answer a graph of arrows which are those resulting from all possible combinations of arrows of the receiver and argument. not implemented yet."
	|newArrowGraph|
	newArrowGraph _ (ArrowGraph new: tally).
	^ newArrowGraph! !
	"Allows the system to completely implement the receiver. The inner set is treated as the actual graph.  This is useful when the intension is incomputable, as is the case for user-level choices."
	infinitary _ false! !
	"Forces evaluation to be strictly lazy, treating the inner set as a cache. This should be used whenever graph definition is intensional, even if the extension of the graph is finite, since the algorithm is only used in case the cache doesn't contain the queried arrow."
	infinitary _ true! !
	^self finite! !
	"Answers whether the internal cache should be treated as the graph itself."
	^ infinitary not! !
	"Answers whether the argument is part of the receiver."
	"This method over-rides the set method to allow for intensional description of graphs and their arrows, which will permit infinitary graphs.  The intensional search should be implemented after the cache is searched."
	(cache includes: anArrow)
		ifFalse: ["Check intension and return false if necessary."].
	^true! !
	"Answers whether the receiver contains arrows which reference the argument."
	"This method over-rides the set method to allow for intensional description of graphs and their arrows, which will permit infinitary graphs.  The intensional search should be implemented after the internal cache is searched."
	(cache isEmpty) ifTrue: [^ false].
	cache do: [:eachArrow | (eachArrow ifReferences: anArrow) ifTrue: [^true]].
	^ false! !
	"Answers if evaluation should be strictly lazy."
	^ infinitary! !
	^self infinitary! !
	"Answers whether the graph 'speaks about' its own arrows. If true, then the graph cannot represent a first-order relation."
	^ self isMetaGraphOf: self! !
	"Answers whether the receiver constitutes a valid first-order logical relation.  It also addresses whether the graph's arrows refer to the graph itself."
	^ self isNonDegenerate & (self includesReferencesTo: self)! !
	"Answers whether the receiver is valid as a first-order relation."
	^ self isDegenerate not! !
	"Answers a new node for the world and names it."
	^ NulArrow deepCopy uiName: aString! !
	^ ArrowGraph new intension: anArrow! !
	"Answers a new node for the world."
	^ NulArrow deepCopy uiName: 'New Node'! !
	"Answers whether the argument is a node."
	^ anArrow head == NulArrow & anArrow isIdentity! !
	^ foo! !
	(anArrow isKindOf: Arrow)
		ifTrue: [foo _ anArrow].! !
	(anArrow isKindOf: Arrow)
		ifTrue: [foo _ anArrow].! !