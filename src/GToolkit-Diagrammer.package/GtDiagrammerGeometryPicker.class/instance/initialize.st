initialization
initialize
	super initialize.

	self constraintsDo: [ :c |
		c horizontal fitContent.
		c vertical fitContent ].
	self geometries: self defaultGeometries