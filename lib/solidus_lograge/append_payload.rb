module SolidusLograge::AppendPayload
  private

  def append_info_to_payload(payload)
    super
    payload[:ip] = request.remote_ip
    payload[:host] = request.host
    payload[:user_agent] = request.user_agent
    payload[:masquerading_user] = masquerading_user
    payload[:order] = order_number
  end

  def masquerading_user
    session["devise_masquerade_spree_user"]
  end

  def order_number
    order.try!(:number)
  end

  def order
    @current_order
  end
end
