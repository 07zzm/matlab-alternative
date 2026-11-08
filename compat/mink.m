function [B, I] = mink(A, k, dim)
% MINK  K smallest elements (MATLAB compatibility shim for GNU Octave).
%
%   B = MINK(A,k) returns the k smallest elements of A.
%   [B,I] = MINK(A,k) also returns the indices I such that B = A(I).
%   MINK(A,k,dim) operates along dimension dim.
%
%   Octave 11.3 does not implement MINK; this shim adds it.
  if (nargin < 2 || isempty(k))
    k = 1;
  end
  if (nargin < 3 || isempty(dim))
    dim = find(size(A) > 1, 1);
    if (isempty(dim))
      dim = 1;
    end
  end

  [S, I] = sort(A, dim, 'ascend');
  n = size(A, dim);
  k = min(max(round(k), 0), n);

  idx = repmat({':'}, 1, max(ndims(A), 2));
  idx{dim} = 1:k;
  B = S(idx{:});
  I = I(idx{:});
end
