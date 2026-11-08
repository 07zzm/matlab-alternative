# -*- coding: utf-8 -*-
"""写 Jupyter 深色主题 + 更好的默认配置"""
import os
from pathlib import Path

root = Path(r"D:\GitHub_Project\craft-anything\research")
jcfg = root / ".jupyter-config"
jdata = root / ".jupyter-data"
jcfg.mkdir(exist_ok=True)
jdata.mkdir(exist_ok=True)
(jdata / "lab" / "user-settings").mkdir(parents=True, exist_ok=True)

# 1) jupyter_server_config.py
cfg = f"""# 科研环境 Jupyter Server 配置
c = get_config()
c.ServerApp.token = ''
c.ServerApp.password = ''
c.ServerApp.open_browser = False
# 尝试固定深色主题（首次启动用户可手动 Settings → Theme 切换）
try:
    c.LabApp.default_theme = 'JupyterLab Dark'
except AttributeError:
    pass
c.ServerApp.root_dir = r'{root}'
"""
(jcfg / "jupyter_server_config.py").write_text(cfg, encoding="utf-8")

# 2) lab user settings (JSON) —— 深色主题 + 行号 + 更舒适的排版
settings = {
    "@jupyterlab/apputils-extension:themes": {"theme": "JupyterLab Dark"},
    "@jupyterlab/notebook-extension:tracker": {
        "codeCellConfig": {"lineNumbers": True, "defaultLineHeight": 1.4, "fontFamily": "Menlo, Consolas, monospace"},
        "markdownCellConfig": {},
        "rawCellConfig": {}
    },
    "@jupyterlab/console-extension:tracker": {"lineNumbers": True},
    "@jupyterlab/fileeditor-extension": {"editorConfig": {"lineNumbers": True}},
    "@jupyterlab/shortcuts-extension": {"shortcuts": []},
    "jupyterlab-shell": {},
    "@jupyterlab/statusbar": {"showStatusBar": True},
}
import json
(jdata / "lab" / "user-settings" / "settings.jupyterlab-settings").write_text(
    json.dumps(settings, indent=2), encoding="utf-8")

# 3) 也写一份经典 notebook 配置（如果用户用 notebook 界面）
nb_cfg = jdata / "nbconfig" / "notebook.json"
nb_cfg.parent.mkdir(parents=True, exist_ok=True)
nb_cfg.write_text(json.dumps({"load_extensions": {"equation-numbering/main": True},
                               "CodeCell": {"cm_config": {"lineNumbers": True}}}, indent=2),
                  encoding="utf-8")

print("ok: dark theme + user settings written")
for p in jcfg.iterdir(): print("  ", p.name)
for p in (jdata / "lab" / "user-settings").iterdir(): print("  ", p)
