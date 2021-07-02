defmodule Honor.Util do
  def fetch_user_safe(data) do
    if data.user_id == nil do
      data.member.user.id
    else
      data.user_id
    end
  end
end