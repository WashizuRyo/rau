module SessionsHelper

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
    session[:session_token] = user.session_token
  end

  # 永続的セッションのためにデータベースに記憶する
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 記憶トークンcookieに対応するユーザを返す
  def current_user
    if (user_id = session[:user_id])
      user ||= User.find_by(id: user_id)
      if user && session[:session_token] == user.session_token
        @current_user = user
      end
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user&.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # ユーザがログインしていればtrue, その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # 永続的セッションを破棄する
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # 現在のユーザをログアウトする
  def log_out
    forget(current_user)
    reset_session
    @current_user = nil
  end

  # 渡されたユーザがカレントユーザであればtrueを返す
  def current_user?(user)
    user&.== current_user
  end

  # アクセスしようとしたURLを保存する
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
