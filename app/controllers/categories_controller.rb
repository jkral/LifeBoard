class CategoriesController < ApplicationController
  before_action :require_authentication
  before_action :set_category, only: [:show]

  def show
    @subcategories = @category.subcategories.active.order(:position)
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end
end
