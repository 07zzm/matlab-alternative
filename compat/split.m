function parts = split(str, delim)
% SPLIT  Split string at delimiter (MATLAB compatibility shim).
%
%   PARTS = SPLIT(STR)        splits at whitespace (like MATLAB).
%   PARTS = SPLIT(STR,DELIM)  splits at the delimiter string DELIM.
%   STR may also be a cell array of char vectors; then PARTS is a cell array
%   holding one cell-of-parts per input string, as in MATLAB.
%
%   Octave 11.3 does not implement SPLIT; this shim adds it.
  if (nargin < 2)
    has_delim = false;
    delim = '';
  else
    has_delim = true;
  end

  if (iscell(str))
    parts = cell(size(str));
    for i = 1:numel(str)
      parts{i} = local_split(str{i}, delim, has_delim);
    end
  else
    parts = local_split(str, delim, has_delim);
  end
end

function p = local_split(s, d, has_delim)
  if (has_delim && ~isempty(d))
    p = strsplit(s, d);
  else
    p = strsplit(s);
  end
end
