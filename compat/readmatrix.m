function M = readmatrix(filename, varargin)
% READMATRIX  Read a numeric matrix from a file (MATLAB compat shim).
%
%   M = READMATRIX(FILENAME) reads numeric data from a text or spreadsheet
%   file.  The delimiter is chosen from the extension:
%     .csv / .txt / .dat  -> comma-separated text (via DLMREAD)
%     .xlsx / .xls        -> spreadsheet (via XLSREAD, needs the io package)
%
%   Octave 11.3 does not implement READMATRIX.  Advanced MATLAB options
%   (Range, Sheet, OutputType, ...) are not supported by this shim.
  if (nargin < 1)
    error('readmatrix: filename required');
  end

  [~, ~, ext] = fileparts(filename);
  switch (lower(ext))
    case {'.xlsx', '.xls', '.ods'}
      try
        M = xlsread(filename);
      catch err
        error('readmatrix: cannot read "%s" (%s). Is the io package loaded?', ...
              filename, err.message);
      end
    case {'.csv', '.txt', '.dat', '.tsv'}
      delim = ',';
      if (strcmpi(ext, '.tsv'))
        delim = '\t';
      end
      M = dlmread(filename, delim);
    otherwise
      M = dlmread(filename);
  end
end
