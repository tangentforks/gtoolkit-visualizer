instance creation
create
	^ (BlPolygon vertices: ({
		50@0.
		65@40.
		100@40.
		75@60.
		85@100.
		50@80.
		15@100.
		25@60.
		0@40.
		35@40.
	} collect: [ :each | each * 2 ])) asElement