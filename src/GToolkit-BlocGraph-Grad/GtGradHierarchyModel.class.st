Class {
	#name : #GtGradHierarchyModel,
	#superclass : #Object,
	#instVars : [
		'roots',
		'ranks',
		'parent',
		'maxRank',
		'hierarchyNodesDictionary'
	],
	#category : #'GToolkit-BlocGraph-Grad-Hierarchical'
}

{ #category : #'instance creation' }
GtGradHierarchyModel class >> directedToUndirectedRatio: aSourceElement target: aTargetElement [
	| directedCount undirectedCount |
	directedCount := 0.
	undirectedCount := 0.
	aSourceElement nodesAlongOutgoingEdges do: [ :aConnectedElement |
		aConnectedElement = aTargetElement
			ifTrue: [ 
				undirectedCount := undirectedCount + 1.
			]
	].
	undirectedCount := directedCount.
	aSourceElement nodesAlongIncomingEdges do: [ :aConnectedElement |
		aConnectedElement = aTargetElement
			ifTrue: [ 
				directedCount := directedCount + 1.
			]
	].	
	^ directedCount / undirectedCount


]

{ #category : #'instance creation' }
GtGradHierarchyModel class >> from: aCollectionOfElements [
	"Create an internal hierarchy model"
	| nodesDictionary connectedElementsDictionary |
	nodesDictionary := IdentityDictionary new.
	"For each key value pair in this dictionary there a hierachy edge is constructed"
	connectedElementsDictionary := IdentityDictionary new.
	aCollectionOfElements do: [ :anElement |
		| connectedElements aHierarchyNode|
		connectedElementsDictionary at: anElement ifAbsentPut: OrderedCollection new.
		connectedElements := connectedElementsDictionary at: anElement.
		(nodesDictionary includesKey: anElement)
			ifFalse: [
				nodesDictionary at: anElement put: (GtGradHierarchyNode on: anElement).
			].
		aHierarchyNode := nodesDictionary at: anElement.
		anElement nodesAlongOutgoingEdges do: [ :anOutgoingElement |
			anOutgoingElement ~= anElement
				ifTrue: [
					| otherElementConnectedElements |
					connectedElementsDictionary at: anOutgoingElement ifAbsentPut: OrderedCollection new.
					otherElementConnectedElements := connectedElementsDictionary at: anOutgoingElement.
					((connectedElementsDictionary includes: anOutgoingElement) or: [ otherElementConnectedElements includes: anElement ])
						ifFalse: [ 
							"All edges between this source and its targets need to be processed
							If there are back edges which create loops, they are callected into one
							hierarchical edge.
							It is assumed that source to targed is the natural direction if at least half
							of the edges are going in that direction."
							 (self directedToUndirectedRatio: anElement target: anOutgoingElement) > 0.5
								ifTrue: [
									| hierarchyEdge targetHierarchyNode|
									(nodesDictionary includesKey: anOutgoingElement)
										ifFalse: [
											nodesDictionary at: anOutgoingElement put: (GtGradHierarchyNode on: anOutgoingElement).
										].
									targetHierarchyNode := nodesDictionary at: anOutgoingElement.
									hierarchyEdge := GtGradHierarchyEdge on: aHierarchyNode target: targetHierarchyNode.
									connectedElements add: anOutgoingElement.
									aHierarchyNode outgoingEdges add: hierarchyEdge.
									targetHierarchyNode incomingEdges add: hierarchyEdge.
								].
						].
				].			
			].
	].
	^ self new hierarchyNodesDictionary: nodesDictionary.

			
	
]

{ #category : #'layout - computations' }
GtGradHierarchyModel >> calculateInitialRank [
	| startNodes startNodesCopy |
	
	startNodes := self rootNodes.
	startNodesCopy := OrderedCollection new: startNodes.
		
	[ startNodes isNotEmpty ]
		whileTrue: [ 
			| layerValue loopCounter aNode layerDetermeningEdges edgesToBeMarked allEdgesVisited minimumLayer |
			aNode := startNodes first.
			layerDetermeningEdges := aNode incomingEdges.
			edgesToBeMarked := aNode outgoingEdges.
			allEdgesVisited := true.
			minimumLayer :=  SmallInteger maxVal.
			loopCounter := 1.
			"TODO why this value?? - can this be a random value?"
			layerValue := 5270620.
			(allEdgesVisited and: [ loopCounter <= layerDetermeningEdges count ])
				whileTrue: [ 
					| hierarchyEdge	|
					hierarchyEdge := layerDetermeningEdges at: loopCounter.
					hierarchyEdge layer = layerValue
						ifTrue: [
							| otherNode |
							otherNode := hierarchyEdge source.
							minimumLayer := minimumLayer min: (otherNode layer - 1).
						]
						ifFalse: [ 
							allEdgesVisited := false	
						]
				 ].
			allEdgesVisited
				ifTrue: [ 
					aNode layer: minimumLayer.
					self maxRank: (self maxRank min: minimumLayer).
					edgesToBeMarked isNotNil
						ifTrue: [ 
							edgesToBeMarked do: [ :anEdgeToBeMarked |
								| otherNode |
								anEdgeToBeMarked layer: layerValue.
								otherNode := anEdgeToBeMarked target.
								otherNode layer = -1
									ifTrue: [ 
										startNodes add: otherNode.
										"Mark this node as neither assigned nor assigned.
										It won't be taken into consideration in any calculation"
										otherNode layer: -2.
									].	
							]
						].
					startNodes removeFirst
				]
				ifFalse: [ 
					| removedNode |
					removedNode := startNodes removeFirst.
					startNodes add: aNode.
					(removedNode = aNode and: [ startNodes count = 1])
						ifTrue: [ 
							"Error condition - break out of the loop"
							startNodes removeAll.
						]
				]
		].
	"Normalize the ranks"
	hierarchyNodesDictionary valuesDo: [ :aNode |
		aNode layer: (aNode layer - self maxRank).
	].
	
	startNodesCopy do: [ :aNode |
		 | currentMaxLayer |
		currentMaxLayer := 0.
		aNode incomingEdges do: [ :anEdge |
			| otherNode |
			otherNode := anEdge source.
			aNode layer: (currentMaxLayer max: otherNode layer + 1).
			currentMaxLayer := aNode layer.
		].
	].
	self maxRank: (SmallInteger maxVal - self maxRank)
	
]

{ #category : #'layout - computations' }
GtGradHierarchyModel >> dfs: aRootNode parent: theParentNode connectingEdge: theConnectingEdge visitor: visitor visitedNodes: aVisitedNodesCollection layer: theLayer [
	aRootNode isNil
		ifTrue: [ ^ self].
	(aVisitedNodesCollection includes: aRootNode)
		ifFalse: [ 
			visitor visit: aRootNode
					  parent: parent
					  connectingEdge: theConnectingEdge
					  layer: theLayer
					  visited: false.
			aVisitedNodesCollection add: aRootNode.
			aRootNode outgoingEdges do: [ :anOutgoingEdge|
				self dfs: anOutgoingEdge target
					  parent: aRootNode
					  connectingEdge: anOutgoingEdge
					  visitor: visitor
					  visitedNodes: aVisitedNodesCollection
					  layer: theLayer + 1.
			]
		]
		ifTrue: [ 
			visitor visit: aRootNode
			 		  parent: parent
					  connectingEdge: theConnectingEdge
					  layer: theLayer
					  visited: true.
		].
]

{ #category : #'layout - computations' }
GtGradHierarchyModel >> dfs: aRootNode parent: theParentNode connectingEdge: theConnectingEdge visitor: visitor visitedNodes: aVisitedNodesCollection parentHashCode: theParentHashCode childHash: theChildHash layer: theLayer [
	aRootNode isNil
		ifTrue: [ ^ self].
	theParentNode isNotNil
		ifTrue: [ 
			(aRootNode hashCode isNil or: [ aRootNode hashCode first ~= theParentNode hashCode first ])
				ifTrue: [ 
					aRootNode hashCode: (OrderedCollection new: theParentNode hashCode).
					aRootNode hashCode add: theChildHash.
				]
			].
		
		(aVisitedNodesCollection includes: aRootNode)
			ifFalse:[
				visitor visit: aRootNode
						  parent: theParentNode
     					  connectingEdge: theConnectingEdge
     					  layer: theLayer
						  visited: false.
				aVisitedNodesCollection add: aRootNode.
				aRootNode outgoingEdges doWithIndex: [ :anEdge :theIndex |
						self dfs: anEdge destination 
								 parent: aRootNode
								 connectingEdge: anEdge
								 visitor: visitor
								 visitedNodes: aVisitedNodesCollection
								 parentHashCode: aRootNode hashCode 
								 childHash: theIndex
								 layer: theLayer + 1
					]
						
			].

			visitor visit: aRootNode
			 		  parent: parent
					  connectingEdge: theConnectingEdge
					  layer: theLayer
					  visited: true.

]

{ #category : #'layout - computations' }
GtGradHierarchyModel >> fixRanks [
	| rootNodes visitor |
	self ranks: ((1 to: maxRank + 1) collect: [ :aNumber|
		Set	 new.
	]).
	
	"Performm DFS to calculate initial ordering for each rank"
	rootNodes := nil.
	self roots isNotNil
		ifTrue: [
				rootNodes := self roots collect: [ :aRootElement |
					 hierarchyNodesDictionary at: aRootElement
				].
		].
	visitor := GtGradFixRankHierarchyVisitor new rankCollection: self ranks.
	self visit: visitor dfsRoots: rootNodes trackAncestors: false visitedNodes: OrderedCollection new.
]

{ #category : #accessing }
GtGradHierarchyModel >> hierarchyNodesDictionary [
	^ hierarchyNodesDictionary
]

{ #category : #accessing }
GtGradHierarchyModel >> hierarchyNodesDictionary: anObject [
	hierarchyNodesDictionary := anObject
]

{ #category : #initialization }
GtGradHierarchyModel >> initialize [
	super initialize.
	self maxRank: SmallInteger maxVal
]

{ #category : #accessing }
GtGradHierarchyModel >> maxRank [
	^ maxRank
]

{ #category : #accessing }
GtGradHierarchyModel >> maxRank: anObject [
	maxRank := anObject
]

{ #category : #accessing }
GtGradHierarchyModel >> parent [
	^ parent
]

{ #category : #accessing }
GtGradHierarchyModel >> parent: anObject [
	parent := anObject
]

{ #category : #accessing }
GtGradHierarchyModel >> ranks [
	^ ranks
]

{ #category : #accessing }
GtGradHierarchyModel >> ranks: anObject [
	ranks := anObject
]

{ #category : #accessing }
GtGradHierarchyModel >> rootNodes [
	| aRootElementsCollection |
	aRootElementsCollection := OrderedCollection new.
	self roots isNotNil
		ifTrue: [ 
			self roots do: [ :aRoot |
				(self hierarchyNodesDictionary includesKey: aRoot)
					ifTrue: [ 
						aRootElementsCollection add: (self hierarchyNodesDictionary at: aRoot)
					]		
			].	
		].
	^ aRootElementsCollection
]

{ #category : #accessing }
GtGradHierarchyModel >> roots [
	^ roots
]

{ #category : #accessing }
GtGradHierarchyModel >> roots: anObject [
	roots := anObject
]

{ #category : #'layout - computations' }
GtGradHierarchyModel >> visit: visitor dfsRoots: aDfsRootsCollection trackAncestors: shouldTrackAncestors visitedNodes: aVisitedNodesCollection [
	aDfsRootsCollection isNil
		ifTrue: [ ^ self	].
	aDfsRootsCollection do: [ :aDfsRoot|
		| aRootNode |
		(self hierarchyNodesDictionary includesKey: aDfsRoot)
			ifTrue: [ 
				aRootNode := self hierarchyNodesDictionary: aDfsRoot.
				"TODO: if track ancestors - figure out what's up with that"
				self dfs: aRootNode parent: nil connectingEdge: nil visitor: visitor  visitedNodes: aVisitedNodesCollection layer: 1.
			].
		
	].
]