function tf = matches(str, pat)
% MATCHES  True if string matches pattern exactly (MATLAB compat shim).
%
%   TF = MATCHES(STR,PAT) is true where STR equals PAT.
%   STR and PAT may each be a char row vector or a cell array of char vectors.
%
%   Octave 11.3 does not implement MATCHES; this shim adds it.
  if (iscell(pat))
    pats = pat(:);
  else
    pats = {pat};
  end

  if (iscell(str))
    tf = false(size(str));
    for i = 1:numel(str)
      tf(i) = local_eq(str{i}, pats);
    end
  else
    tf = local_eq(str, pats);
  end
end

function tf = local_eq(s, pats)
  tf = false;
  for j = 1:numel(pats)
    if (strcmp(s, pats{j}))
      tf = true;
      return;
    end
  end
end
