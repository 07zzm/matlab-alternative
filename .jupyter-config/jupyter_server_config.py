# 科研环境 Jupyter Server 配置
c = get_config()
c.ServerApp.token = ''
c.ServerApp.password = ''
c.ServerApp.open_browser = False
# 尝试固定深色主题（首次启动用户可手动 Settings → Theme 切换）
try:
    c.LabApp.default_theme = 'JupyterLab Dark'
except AttributeError:
    pass
c.ServerApp.root_dir = r'D:\GitHub_Project\craft-anything\research'
