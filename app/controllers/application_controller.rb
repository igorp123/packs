class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :notfound

  private

  def notfound
    render file: 'public/404.html', status: :not_found, layout: false
  end
end
