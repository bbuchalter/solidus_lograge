module SolidusLograge::AppendPayload
  private

  def append_info_to_payload(payload)
    super
    payload[:ip] = request.remote_ip
    payload[:host] = request.host
    payload[:user_agent] = request.user_agent
    payload[:masquerading_user] = masquerading_user
  end

  def masquerading_user
    session["devise_masquerade_spree_user"]
  end
end
