function tf = contains(str, pat, varargin)
% CONTAINS  True if string contains pattern (MATLAB compatibility shim).
%
%   TF = CONTAINS(STR,PAT) returns true where STR contains PAT.
%   STR may be a char row vector or a cell array of char vectors.
%   PAT may be a char row vector or a cell array of char vectors.
%   CONTAINS(...,'IgnoreCase',true) matches case-insensitively.
%
%   Octave 11.3 does not implement CONTAINS; this shim adds it.
  ignore_case = false;
  for k = 1:2:numel(varargin)
    if (strcmpi(varargin{k}, 'IgnoreCase'))
      ignore_case = logical(varargin{k+1});
    else
      error('contains: unknown option "%s"', varargin{k});
    end
  end

  if (ignore_case)
    str = lower(str);
    pat = lower(pat);
  end

  if (iscell(pat))
    pats = pat;
  else
    pats = {pat};
  end

  if (iscell(str))
    tf = false(size(str));
    for i = 1:numel(str)
      tf(i) = local_any(str{i}, pats);
    end
  else
    tf = local_any(str, pats);
  end
end

function tf = local_any(s, pats)
  tf = false;
  for j = 1:numel(pats)
    if (~isempty(strfind(s, pats{j})))  %#ok<STREMP>
      tf = true;
      return;
    end
  end
end
