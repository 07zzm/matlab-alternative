function h = tiledlayout(m, n)
% TILEDLAYOUT  Tiled chart layout (MATLAB compatibility shim).
%
%   TILEDLAYOUT(M,N) starts an M-by-N tiled layout in the current figure.
%   Use NEXT TILE to select the next tile.
%
%   This is a lightweight shim: it stores the grid in the figure's app data
%   and NEXT TILE maps onto SUBPLOT.  Spacing/TileSpacing properties are not
%   implemented.  Octave 11.3 has no TILEDLAYOUT at all.
  if (nargin < 2)
    error('tiledlayout: use tiledlayout(m,n) — the ''flow''/''vertical'' layouts are not supported by this shim');
  end

  setappdata(gcf, 'tiledlayout_state', [m n 0]);
  h = gcf;
end
