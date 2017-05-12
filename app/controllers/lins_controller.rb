class LinsController < ApplicationController
  skip_before_action :authenticate_request
  before_action :set_categ
  before_action :set_lin, only: [:show, :update, :destroy]

  # GET /lins
  def index
    render json: @categ.lins
  end

  # GET /lins/1
  def show
    render json: @lin
  end

  # POST /lins
  def create
    @categ.lins.create!(lin_params)

    if @categ.save
      render json: @categ, status: :created
    else
      render json: @categ.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /lins/1
  def update
    if @lin.update(lin_params)
      render json: @lin
    else
      render json: @lin.errors, status: :unprocessable_entity
    end
  end

  # DELETE /lins/1
  def destroy
    if @lin.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private
    # Get the :category_id first
    def set_categ
      @categ = Categ.find(params[:categ_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_lin
      @lin = Lin.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def lin_params
      params.require(:lin).permit(:title, :link_url, :categ_id)
    end
end
