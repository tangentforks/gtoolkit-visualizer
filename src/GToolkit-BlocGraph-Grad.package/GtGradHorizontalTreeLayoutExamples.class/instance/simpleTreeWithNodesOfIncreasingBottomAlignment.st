example
simpleTreeWithNodesOfIncreasingBottomAlignment
	<gtExample>
		
	| view theNodes aTreeLayout |
	
	view := self view. 
	aTreeLayout := self treeLayout.
	aTreeLayout nodesAlignment: GtGradTreeNodesBottomAlignment.
	theNodes := self constructTreeWithNodesOfIncreasingSize key. 
	view addChildren: theNodes. 
	
	view layout: aTreeLayout.
	view forceLayout. 
	  

	^ view