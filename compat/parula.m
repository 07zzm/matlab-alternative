function c = parula(n)
% PARULA  MATLAB's default colormap (compatibility shim for GNU Octave).
%
%   C = PARULA        returns the colormap as a 64-by-3 matrix.
%   C = PARULA(N)     returns an N-by-3 matrix.
%   PARULA            (no output) applies the colormap to the current figure.
%
%   NOTE: this is a smooth approximation built from anchor colours sampled
%   from the MATLAB parula map.  It is visually very close, but it is not a
%   byte-exact copy of MathWorks' table.  Octave 11.3 has no PARULA at all,
%   so MATLAB plotting code fails without this shim.
  if (nargin < 1 || isempty(n))
    n = 64;
  end
  if (n == 1)
    c = [0.2081 0.1663 0.5292];
    if (nargout == 0)
      colormap(c);
      clear c;
    end
    return;
  end

  % Anchor colours of the parula ramp (t = 0 … 1).
  anchors = [ ...
    0.2081 0.1663 0.5292
    0.2116 0.1898 0.5777
    0.2123 0.2513 0.6413
    0.1856 0.3213 0.6646
    0.0874 0.4129 0.6295
    0.0159 0.4897 0.5576
    0.1062 0.5566 0.4759
    0.3340 0.6143 0.4051
    0.6304 0.6792 0.3207
    0.8768 0.7559 0.2574
    0.9763 0.9831 0.0538];

  t  = linspace(0, 1, rows(anchors));
  ti = linspace(0, 1, n);
  c  = [interp1(t, anchors(:,1), ti)', ...
        interp1(t, anchors(:,2), ti)', ...
        interp1(t, anchors(:,3), ti)'];
  c = min(max(c, 0), 1);

  if (nargout == 0)
    colormap(c);
    clear c;
  end
end
