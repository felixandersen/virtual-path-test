module ApplicationHelper
  def key_fix(key)
    "#{controller_path.tr('/', '.') }.#{ action_name }#{ key }"
  end
end
