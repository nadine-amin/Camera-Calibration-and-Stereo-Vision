% Reconstruct3D		: Reconstructs the 3D points of an object given its images and the projection matrices
%	mk(440,2,2/3)	: The images of the 3D points
%	Pk(3,4,2/3)		: The projection matrices
%	shape3D(440,3)	: The 3D points of the object
%	A(3,3,2/3)		: The matrix described in reconstruct.pdf (it is reused for all points)
function shape3D = Reconstruct3D( mk, Pk )
	% Number of points in the 3D object
	numOfPoints	= size( mk, 1 );
	
	% Number of the images taken for the object
	% (take minimum for exception handling, if one of them is less than the other)
	numOfViews	= min( size( mk, 3 ), size( Pk, 3 ) );
	
	% Preallocate variables for performance, these are used later
	uk = zeros( numOfPoints, 3, numOfViews );
	shape3D = zeros( numOfPoints, 3 );
	Ak = zeros( 3, 3, numOfViews );
	Ck = zeros( 3, numOfViews );
	
	Bk( :, :, : ) = Pk( :, 1 : 3, : );	% Bk is the left 3*3 submatrix of Pk
	bk( :, :, : ) = Pk( :, 4, : );		% bk is the right 3*1 vector of Pk
	
	% 3
	for k = 1 : numOfViews
		% Inverse of Bk( :, :, k )
		invBk = inv( Bk( :, :, k ) );
		
		% Estimate the optical centers (Dr. Essa gave us this method in the lecture)
		Ck( :, k ) = -invBk * bk( :, :, k );
		
		% Loop on all points (440)
		for i = 1 : numOfPoints
			% Uk is is a temp variable used for all uk before normalization
			Uk	= invBk * ( [mk( i, :, k )'; 1] - bk( :, :, k ) ) - Ck( :, k );
			
			% Normalize (and change Uk back to row vector)
			uk( i, :, k ) = Uk' / norm( Uk );
		end
	end
	
	% Construct the 3D points
	for i = 1 : numOfPoints
		% Initialize an accumulator for the second sum used in equation 6
		sumAkCk = [0; 0; 0;];
		
		for k = 1 : numOfViews
			% Construct the Ak matrix for point # i
			Ak( :, :, k ) = [uk( i, 2, k ) ^ 2 + uk( i, 3, k ) ^ 2		uk( i, 1, k ) * -uk( i, 2, k )				uk( i, 1, k ) * -uk( i, 3, k );
							-uk( i, 1, k ) * uk( i, 2, k )				uk( i, 1, k ) ^ 2 + uk( i, 3, k ) ^ 2		uk( i, 2, k ) * -uk( i, 3, k );
							-uk( i, 1, k ) * uk( i, 3, k )				-uk( i, 2, k ) * uk( i, 3, k )				uk( i, 1, k ) ^ 2 + uk( i, 2, k ) ^ 2 ];
			
			% The summation
			sumAkCk = sumAkCk + Ak( :, :, k ) * Ck( :, k );
		end
		
		% Construct the 3D point # i
		% Transpose to reshape it into 1-by-3 vector (thought it worked without the transpose)
		shape3D( i, : ) = ( sum( Ak, 3 ) \ sumAkCk )';
	end
end