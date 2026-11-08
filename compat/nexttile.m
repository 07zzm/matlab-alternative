function ax = nexttile(k)
% NEXTTILE  Select next tile in a tiled layout (MATLAB compatibility shim).
%
%   AX = NEXTTILE       advances to the next tile and returns its axes.
%   AX = NEXTTILE(K)    selects tile K explicitly.
%
%   Requires a prior TILEDLAYOUT(M,N) call in the same figure.
  s = getappdata(gcf, 'tiledlayout_state');
  if (isempty(s))
    error('nexttile: call tiledlayout(m,n) first');
  end

  if (nargin < 1 || isempty(k))
    s(3) = s(3) + 1;
  else
    s(3) = k;
  end

  if (s(3) > s(1)*s(2))
    error('nexttile: tile index %d exceeds the %d-by-%d layout', s(3), s(1), s(2));
  end

  setappdata(gcf, 'tiledlayout_state', s);
  ax = subplot(s(1), s(2), s(3));
end
