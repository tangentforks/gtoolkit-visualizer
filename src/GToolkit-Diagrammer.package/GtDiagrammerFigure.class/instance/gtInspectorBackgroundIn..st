gt-inspector-extension
gtInspectorBackgroundIn: aComposite
	<gtInspectorPresentationOrder: 13>

	^ aComposite bloc
		title: 'Background';
		element: [
			| container presenter picker |
			container := BlElement new.
			container padding: (BlInsets all: 10).
			container layout: BlLinearLayout horizontal.
			container constraintsDo: [ :c | 
				c horizontal fitContent.
				c vertical fitContent ].

			presenter := GtDiagrammerColorPresenter new.
			presenter constraintsDo: [ :c | 
				c linear vertical alignCenter ].

			picker := GtDiagrammerColorPicker new.
			picker margin: (BlInsets left: 7).
			picker constraintsDo: [ :c | 
				c linear vertical alignCenter ].

			picker
				when: GtDiagrammerPickerSelected
				do: [ :anEvent | presenter color: anEvent entity ].
			
			picker
				when: GtDiagrammerPickerSelected
				do: [ :anEvent | self background: (BlBackground paint: anEvent entity) ].

			container addChildren: { presenter . picker } ]