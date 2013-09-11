class AuthenticationsController < ApplicationController

  def index
    @authentications = Authentication.all
  end

  def create
    @authentication = Authentication.new(params[:authentication])

    if @authentication.save
      redirect_to authentications_url, :notice => "Successfully created authentication."
    else
      render :action => 'new'
    end
  end

  def destroy
    @authentication = Authentication.find(params[:id])
    @authentication.destroy
    redirect_to authentications_url, :notice => "Successfully destroyed authentication."
  end

  def twitter
    #raise omni = request.env["omniauth.auth"].to_yaml # information twitter
    omni = request.env["omniauth.auth"]  # omni variable is the hash, uid of user is omni['uid']

    #search that whether there exists a record with the following inputs or not
    authentication = Authentication.find_by_provider_and_uid(omni['provider'], omni['uid'])

    if authentication
      flash[:notice] = "Logged in Successfully"
      sign_in_and_redirect User.find(authentication.user_id)
    elsif current_user
      token = omni['credentials'].token
      token_secret = omni['credentials'].secret

      current_user.authentications.create!(:provider => omni['provider'], :uid => omni['uid'], :token => token, :token_secret => token_secret)
      flash[:notice] = "Authentication successful."
      sign_in_and_redirect current_user
    else
      user = User.new
      user.username = omni['info'].nickname
      user.email = "user@provider.com"

      user.apply_omniauth(omni)

      if user.save
        flash[:notice] = "Logged in."
        sign_in_and_redirect User.find(user.id)
      else
        #.except helps us to get rid of a lot of unnecessary information from hash, so that our session hash will not get rejected
        session[:omniauth] = omni.except('extra')
        redirect_to new_user_registration_path
      end
    end
  end

  def facebook
    #raise omni = request.env["omniauth.auth"].to_yaml
    omni = request.env["omniauth.auth"]

    authentication = Authentication.find_by_provider_and_uid(omni['provider'], omni['uid'])

    if authentication
      flash[:notice] = "Logged in Successfully"
      sign_in_and_redirect User.find(authentication.user_id)
    elsif current_user
      token = omni['credentials'].token
      token_secret = omni['credentials'].secret

      current_user.authentications.create!(:provider => omni['provider'], :uid => omni['uid'], :token => token, :token_secret => token_secret)
      flash[:notice] = "Authentication successful."
      sign_in_and_redirect current_user
    else
      user = User.new
      user.email = omni['info'].email
      user.username = omni['info'].nickname

      user.apply_omniauth(omni)

      if user.save
        flash[:notice] = "Logged in."
        sign_in_and_redirect User.find(user.id)
      else
        session[:omniauth] = omni.except('extra')
        redirect_to new_user_registration_path
      end
    end
  end

end
