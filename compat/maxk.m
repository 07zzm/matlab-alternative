function [B, I] = maxk(A, k, dim)
% MAXK  K largest elements (MATLAB compatibility shim for GNU Octave).
%
%   B = MAXK(A,k) returns the k largest elements of A.
%   [B,I] = MAXK(A,k) also returns the indices I such that B = A(I).
%   MAXK(A,k,dim) operates along dimension dim.
%
%   Octave 11.3 does not implement MAXK; this shim adds it so MATLAB code
%   runs unchanged.  See research/compat/README.md.
  if (nargin < 2 || isempty(k))
    k = 1;
  end
  if (nargin < 3 || isempty(dim))
    dim = find(size(A) > 1, 1);
    if (isempty(dim))
      dim = 1;
    end
  end

  [S, I] = sort(A, dim, 'descend');
  n = size(A, dim);
  k = min(max(round(k), 0), n);

  idx = repmat({':'}, 1, max(ndims(A), 2));
  idx{dim} = 1:k;
  B = S(idx{:});
  I = I(idx{:});
end
