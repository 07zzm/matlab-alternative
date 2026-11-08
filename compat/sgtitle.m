function h = sgtitle(txt, varargin)
% SGTITLE  Suptitle for a subplot grid (MATLAB compatibility shim).
%
%   SGTITLE(TXT) adds a centred title above all subplots in the current figure.
%   SGTITLE(TXT,Name,Value,...) forwards text properties (FontSize, ...).
%
%   Octave 11.3 does not implement SGTITLE.
%
%   Implementation note: this shim uses an invisible axes plus a TEXT object
%   rather than ANNOTATION('textbox',...).  The annotation route makes
%   Octave's text renderer emit a stream of "substituting font" warnings for
%   CJK strings in off-screen figures; the TEXT route renders Chinese
%   cleanly with the usual font handling.
  if (nargin < 1)
    error('sgtitle: not enough input arguments');
  end

  % Default to a CJK-capable font unless the caller overrides FontName.
  has_font = false;
  for k = 1:2:numel(varargin)
    if (ischar(varargin{k}) && strcmpi(varargin{k}, 'FontName'))
      has_font = true;
    end
  end

  old_ax = get(gcf, 'currentaxes');

  ax = axes('Parent', gcf, ...
            'Position', [0 0.94 1 0.06], ...
            'Visible', 'off', ...
            'XLim', [0 1], ...
            'YLim', [0 1]);

  if (~has_font)
    set(ax, 'FontName', 'Microsoft YaHei');
  end

  h = text(0.5, 0.5, txt, ...
           'Parent', ax, ...
           'HorizontalAlignment', 'center', ...
           'VerticalAlignment', 'middle', ...
           'Interpreter', 'none', ...
           varargin{:});

  % Do not steal the "current axes" from the plot the user was building.
  if (~isempty(old_ax) && ishandle(old_ax))
    set(gcf, 'currentaxes', old_ax);
  end
end
