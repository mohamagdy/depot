class StoreController < ApplicationController
  before_filter :find_cart, :except => :empty_cart
  
  def index
    @products = Product.find_products_for_sale
    if session[:counter].nil?
      session[:counter] = 1
    else
      session[:counter] = session[:counter] + 1
    end
    @counter = session[:counter]
    @cart = find_cart
  end
  
  def add_to_cart
    product = Product.find(params[:id])
    @current_item = @cart.add_product(product)
    respond_to do |format|
      format.js if request.xhr?
      format.html {redirect_to_index}
    end
  rescue ActiveRecord::RecordNotFound
    logger.error("Attempt to access invalid product #{params[:id]}" )
    redirect_to_index("Invalid product" )
  end
  
  def empty_cart
    session[:cart] = nil
    redirect_to_index
  end
  
  def checkout
    if @cart.items.empty?
      redirect_to_index("Your cart is empty" )
    else
      @order = Order.new
    end
    @check_out = true
  end
  
  def save_order
    @order = Order.new(params[:order])
    @order.add_line_items_from_cart(@cart)
    if @order.save
      session[:cart] = nil
      redirect_to_index(I18n.t('flash.thanks' ))
    else
      render :action => 'checkout'
    end
  end
  
  protected
  def authorize
  end
  
  
  private
  def find_cart
    @cart = session[:cart] ||= Cart.new
  end
  
  def redirect_to_index(msg)
    flash[:notice] = msg
    redirect_to :action => 'index'
  end
  
  
end
