Class {
	#name : #BaselineOfGToolkitVisualizer,
	#superclass : #BaselineOf,
	#category : 'BaselineOfGToolkitVisualizer'
}

{ #category : #baseline }
BaselineOfGToolkitVisualizer >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec
				baseline: 'Brick' with: [ spec repository: 'github://pharo-graphics/Brick/src' ];
			   baseline: 'Beacon' with: [ spec repository: 'github://pharo-project/pharo-beacon/repository' ];

				package: 'GToolkit-BlocGraph' with: [ spec requires: #(Brick) ];
				package: 'GToolkit-BlocGraph-Grad' with: [ spec requires: #('GToolkit-BlocGraph') ];
				package: 'GToolkit-BlocGraph-Layouts' with: [ spec requires: #('GToolkit-BlocGraph') ];
				
				"GT Mondrian, an engine that offers a fluent API for scripting graph-based visualizations."
				package: 'GToolkit-Mondrian' with: [ spec requires: #(Brick 'GToolkit-BlocGraph' 'GToolkit-BlocGraph-Layouts' 'Beacon') ];
				package: 'GToolkit-Mondrian-Glamour' with: [ spec requires: #('GToolkit-Mondrian') ];
				
				"GT Connector, an engine that offers a visual way to explore examples."
				package: 'GToolkit-Connector' with: [ spec requires: #(Brick 'GToolkit-BlocGraph' 'GToolkit-BlocGraph-Layouts') ];
				
				"GT Diagrammer, an engine for constructing diagrams."
				package: 'GToolkit-Diagrammer' with: [ spec requires: #(Brick) ];
				
				"GT Plotter, an engine that offers a fluent API for scripting charts and plots"
				package: 'GToolkit-Plotter' with: [ spec requires: #(Brick) ] ]
]