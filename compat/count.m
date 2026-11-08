function n = count(str, pat, varargin)
% COUNT  Count occurrences of a pattern (MATLAB compatibility shim).
%
%   N = COUNT(STR,PAT) counts occurrences of PAT in STR.
%   STR may be a char row vector or a cell array of char vectors.
%   COUNT(...,'IgnoreCase',true) matches case-insensitively.
%
%   Octave 11.3 does not implement COUNT; this shim adds it.
  ignore_case = false;
  for k = 1:2:numel(varargin)
    if (strcmpi(varargin{k}, 'IgnoreCase'))
      ignore_case = logical(varargin{k+1});
    else
      error('count: unknown option "%s"', varargin{k});
    end
  end

  if (ignore_case)
    str = lower(str);
    pat = lower(pat);
  end

  if (iscell(str))
    n = zeros(size(str));
    for i = 1:numel(str)
      n(i) = numel(strfind(str{i}, pat));  %#ok<STREMP>
    end
  else
    n = numel(strfind(str, pat));  %#ok<STREMP>
  end
end
