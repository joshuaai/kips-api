class API::V1::LinksController < ApplicationController
  skip_before_action :authenticate_request
  before_action :set_category
  before_action :set_link, only: [:show, :update, :destroy]

  # GET /categories/:category_id/links
  def index
    render json: @category.links
  end

  # GET /categories/:category_id/links/1
  def show
    render json: @link
  end

  # POST /categories/:category_id/links
  def create
    @category.links.create!(link_params)

    if @category.save
      render json: @category, status: :created
    else
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /categories/:category_id/links/1
  def update
    if @link.update(link_params)
      head :no_content
    else
      render json: @link.errors, status: :unprocessable_entity
    end
  end

  # DELETE /categories/:category_id/links/1
  def destroy
    @link.destroy
    head :no_content
  end

  private
    # Get the :category_id first
    def set_category
      @category = Category.find(params[:category_id])
    end
  
    # Use callbacks to share common setup or constraints between actions.
    def set_link
      @link = Link.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def link_params
      params.require(:link).permit(:title, :link_url, :category_id)
    end
end
