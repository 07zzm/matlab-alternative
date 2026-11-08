function writematrix(M, filename, varargin)
% WRITEMATRIX  Write a numeric matrix to a file (MATLAB compat shim).
%
%   WRITEMATRIX(M,FILENAME) writes M to a text or spreadsheet file:
%     .csv / .txt / .dat  -> comma-separated text (via DLMWRITE)
%     .xlsx / .xls        -> spreadsheet (via XLSWRITE, needs io package)
%
%   Octave 11.3 does not implement WRITEMATRIX.  Advanced MATLAB options
%   (Sheet, Range, Delimiter, ...) are not supported by this shim.
  if (nargin < 2)
    error('writematrix: matrix and filename required');
  end

  [~, ~, ext] = fileparts(filename);
  switch (lower(ext))
    case {'.xlsx', '.xls', '.ods'}
      try
        xlswrite(filename, M);
      catch err
        error('writematrix: cannot write "%s" (%s). Is the io package loaded?', ...
              filename, err.message);
      end
    case '.tsv'
      dlmwrite(filename, M, '\t');
    otherwise
      dlmwrite(filename, M, ',');
  end
end
